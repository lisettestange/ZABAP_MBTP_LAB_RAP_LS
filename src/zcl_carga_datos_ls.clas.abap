CLASS zcl_carga_datos_ls DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_carga_datos_ls IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA: lt_travel   TYPE TABLE OF ztb_travel_ls,
          lt_booking  TYPE TABLE OF ztb_booking_ls,
          lt_book_sup TYPE TABLE OF ztb_booksuppl_ls.


*   Busca la data de la tabla Travel y lo deja en la tabla interna lt_travel
    SELECT travel_id,
    agency_id,
    customer_id,
    begin_date,
    end_date,
    booking_fee,
    total_price,
    currency_code,
    description,
    status AS overall_status,
    createdby AS created_by,
    createdat AS created_at,
    lastchangedby AS last_changed_by,
    lastchangedat AS last_changed_at
    FROM /dmo/travel INTO CORRESPONDING FIELDS OF TABLE @lt_travel
    UP TO 50 ROWS.

*   Busca la data de la tabla booking y lo deja en la tabla interna lt_booking
    SELECT * FROM /dmo/booking
    FOR ALL ENTRIES IN @lt_travel
    WHERE travel_id EQ @lt_travel-travel_id
    INTO CORRESPONDING FIELDS OF TABLE @lt_booking.

*   Busca la data de la tabla book_sup y lo deja en la tabla interna lt_book_sup
    SELECT * FROM /dmo/book_suppl
    FOR ALL ENTRIES IN @lt_booking
    WHERE travel_id EQ @lt_booking-travel_id
    AND booking_id EQ @lt_booking-booking_id
    INTO CORRESPONDING FIELDS OF TABLE @lt_book_sup.

**********************************************************************
*   Borra la data de las tablas creadas
    DELETE FROM: ztb_travel_ls,
                 ztb_booking_ls,
                 ztb_booksuppl_ls.

    INSERT: ztb_travel_ls FROM TABLE @lt_travel,
    ztb_booking_ls FROM TABLE @lt_booking,
    ztb_booksuppl_ls FROM TABLE @lt_book_sup.
    out->write( 'Tablas con datos!' ).

  ENDMETHOD.
ENDCLASS.
