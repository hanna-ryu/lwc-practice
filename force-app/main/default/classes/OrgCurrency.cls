public with sharing class OrgCurrency {
  public static List<CurrencyType> getOrgCurrencies() {
    List<CurrencyType> ct = [
      SELECT IsoCode, ConversionRate, IsActive
      FROM CurrencyType
      WHERE IsActive = :true
    ];
    return ct;
  }
}
