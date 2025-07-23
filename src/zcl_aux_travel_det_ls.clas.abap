CLASS zcl_aux_travel_det_ls DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: tt_travel_reported     TYPE TABLE FOR REPORTED z_i_travel_ls,
           tt_booking_reported    TYPE TABLE FOR REPORTED Z_I_booking_LS,
           tt_supplement_reported TYPE TABLE FOR REPORTED Z_I_booksuppl_LS.

    TYPES: tt_travel_id TYPE TABLE OF /dmo/travel_id.

    CLASS-METHODS calculate_price IMPORTING it_travel_id TYPE tt_travel_id.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_aux_travel_det_ls IMPLEMENTATION.
  METHOD calculate_price.
    DATA: lv_total_booking_price TYPE /dmo/total_price,
          lv_total_suppl_price   TYPE /dmo/total_price.

    IF it_travel_id IS    INITIAL.
      RETURN.
    ENDIF.

    READ ENTITIES OF z_i_travel_ls
     ENTITY Travel
     FIELDS ( travel_id  currency_code )
     WITH VALUE #( FOR lv_travel_id IN it_travel_id
                    ( travel_id = lv_travel_id ) )
                    RESULT DATA(lt_read_travel).

*     FROM VALUE #( FOR lv_travel_id IN it_travel_id
*                    ( travel_id = lv_travel_id ) )
*                    RESULT DATA(lt_read_travel).

    READ ENTITIES OF z_i_travel_ls
     ENTITY Travel BY \_Booking
     FROM VALUE #( FOR lv_travel_id IN it_travel_id
                    ( travel_id = lv_travel_id
                      %control-flight_price = if_abap_behv=>mk-on
                      %control-currency_code = if_abap_behv=>mk-on ) )
                    RESULT DATA(lt_read_booking).

    LOOP AT lt_read_booking INTO DATA(ls_booking)
            GROUP BY ls_booking-travel_id INTO DATA(lv_travel_key).

      ASSIGN lt_read_travel[ KEY entity COMPONENTS travel_id = lv_travel_key ]
          TO FIELD-SYMBOL(<ls_travel>).

      LOOP AT GROUP lv_travel_key INTO DATA(ls_booking_result)
          GROUP BY ls_booking_result-currency_code INTO DATA(lv_curr).

        lv_total_booking_price = 0.

        LOOP AT GROUP lv_curr INTO DATA(ls_booking_line) .
          lv_total_booking_price += ls_booking_line-flight_price.
        ENDLOOP.

        IF lv_curr EQ <ls_travel>-currency_code.
*        <ls_travel>-total_price = <ls_travel>-total_price + lv_total_booking_price .
          <ls_travel>-total_price +=  lv_total_booking_price .
        ELSE.
          /dmo/cl_flight_amdp=>convert_currency(
              EXPORTING
                  iv_amount                 = lv_total_booking_price
                  iv_currency_code_source  = lv_curr
                  iv_currency_code_target  = <ls_travel>-currency_code
                  iv_exchange_rate_date    = cl_abap_context_info=>get_system_date( )
              IMPORTING
                  ev_amount       = DATA(lv_amount_converted) )   .

          <ls_travel>-total_price +=  lv_amount_converted .
        ENDIF.
      ENDLOOP.

    ENDLOOP.

*hasta este punto ya tenemos actualizado el valor de total price
* a continuacion leemos la entidad de booking

    READ ENTITIES OF z_i_travel_ls
     ENTITY Booking BY \_BookingSupplement
     FROM VALUE #( FOR ls_travel IN lt_read_booking
                    ( travel_id = ls_travel-travel_id
                      booking_id = ls_travel-booking_id
                      %control-price = if_abap_behv=>mk-on
                      %control-currency = if_abap_behv=>mk-on ) )
                    RESULT DATA(lt_read_supplements).

    LOOP AT lt_read_supplements INTO DATA(ls_booking_suppl)
        GROUP BY ls_booking_suppl-travel_id INTO lv_travel_key.

      ASSIGN lt_read_travel[ KEY entity COMPONENTS travel_id = lv_travel_key ]
          TO <ls_travel>.

      LOOP AT GROUP lv_travel_key INTO DATA(ls_supplements_result)
          GROUP BY ls_supplements_result-currency INTO lv_curr.

        lv_total_suppl_price = 0.

        LOOP AT GROUP lv_curr INTO DATA(ls_supplement_line) .
          lv_total_suppl_price += ls_supplement_line-price.
        ENDLOOP.

        IF lv_curr EQ <ls_travel>-currency_code.
          <ls_travel>-total_price +=  lv_total_suppl_price .
        ELSE.
          /dmo/cl_flight_amdp=>convert_currency(
              EXPORTING
                  iv_amount                = lv_total_suppl_price
                  iv_currency_code_source  = lv_curr
                  iv_currency_code_target  = <ls_travel>-currency_code
                  iv_exchange_rate_date    = cl_abap_context_info=>get_system_date( )
              IMPORTING
                  ev_amount       = lv_amount_converted )   .

          <ls_travel>-total_price +=  lv_amount_converted .
        ENDIF.

      ENDLOOP.
    ENDLOOP.

    MODIFY ENTITIES OF z_i_travel_ls
        ENTITY Travel
        UPDATE FROM VALUE #( FOR ls_travel_bo IN lt_read_travel (
                                    travel_id = ls_travel_bo-travel_id
                                    total_price = ls_travel_bo-total_price
                                    %control-total_price = if_abap_behv=>mk-on ) ).

  ENDMETHOD.

ENDCLASS.
