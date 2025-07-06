@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption - Booking Supplement'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity Z_C_BOOKSUPPL_LS
  as projection on Z_I_BOOKSUPPL_LS
{
  key travel_id                   as TravelID,
  key booking_id                  as BookingID,
  key booking_supplement_id       as BookingSupplementID,
//      @ObjectModel.text.element: ['SupplementDescription']
      supplement_id               as SupplementID,
      _SupplementText.Description as SupplementDescription : localized,
      @Semantics.amount.currencyCode : 'CurrencyCode'
      price                       as Price,
      @Semantics.currencyCode: true
      currency                    as CurrencyCode,
//      last_changed_at             as LastChangedAt,
////      /* Associations */
      _Travel  : redirected to Z_C_TRAVEL_LS,
      _Booking : redirected to parent Z_C_BOOKING_LS,
      _Product,
      _SupplementText
}
