CLASS zcl_ext_update_ent_ls DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_ext_update_ent_ls IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

    MODIFY ENTITIES OF z_i_travel_ls
        ENTITY Travel
        UPDATE FIELDS ( agency_id  description )
        WITH VALUE #( ( travel_id = '00000001'
                        agency_id = '070017'
                        description = 'New external update' ) )
        FAILED DATA(failed)
        REPORTED DATA(reported).

    READ ENTITIES OF z_i_travel_ls
        ENTITY Travel
        FIELDS ( agency_id  description )
        WITH VALUE #( ( travel_id = '00000001' ) )
        RESULT DATA(lt_travel_data)
        FAILED  failed
        REPORTED reported.

    COMMIT ENTITIES.

    if failed Is INITIAL.
        out->write( 'Commit Succesfull' ).
    ELSE.
        out->write( 'Commit Failed' ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
