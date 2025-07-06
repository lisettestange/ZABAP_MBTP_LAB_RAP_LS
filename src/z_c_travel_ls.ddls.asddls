@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption - Travel'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity Z_C_TRAVEL_LS
  as projection on Z_I_TRAVEL_LS
{
  key travel_id       as TravelID,
      //      @ObjectModel.text.element: ['AgencyName']
      agency_id       as AgencyID,
      //      _Agency.Name       as AgencyName,
      //      @ObjectModel.text.element: ['CustomerName']
      customer_id     as CustomerID,
      //      _Customer.LastName as CustomerName,
      begin_date      as BeginDate,
      end_date        as EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      booking_fee     as BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      total_price     as TotalPrice,
      @Semantics.currencyCode: true
      currency_code   as CurrencyCode,
      description     as Description,
      overall_status  as TravelStatus,
      last_changed_at as LastChangedAt,
      //      /* Associations */
      _Agency,
      _Booking : redirected to composition child Z_C_BOOKING_LS,
      _Currency,
      _Customer
}
