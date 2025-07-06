@AbapCatalog.sqlViewName: 'ZV_BOOK_LS'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface Booking Suppl'
@Metadata.ignorePropagatedAnnotations: true
define view Z_I_BOOKSUPPL_LS
  as select from ztb_booksuppl_ls as BookingSupplement
  association to parent Z_I_BOOKING_LS as _Booking on $projection.travel_id = _Booking.travel_id    
                                                  and $projection.booking_id = _Booking.booking_id
  association [1..1] to Z_I_TRAVEL_LS as _Travel on $projection.travel_id = _Travel.travel_id
  association [1..1] to /DMO/I_Supplement as _Product on $projection.supplement_id = _Product.SupplementID
  association [1..*] to /DMO/I_SupplementText as _SupplementText on $projection.supplement_id = _SupplementText.SupplementID
{
  key travel_id,
  key booking_id,
  key booking_supplement_id,
      supplement_id,
      @Semantics.amount.currencyCode : 'currency'
      price,
      @Semantics.currencyCode: true
      currency,
      _Booking,
      _Travel,
      _Product,
      _SupplementText
}
