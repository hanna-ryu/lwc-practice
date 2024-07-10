public with sharing class OrgCurrency {
  private static String orgCurr;

  public static String getOrgCurrency() {
    /* 
    UserInfo를 반환
    orgCurr = UserInfo.getDefaultCurrency();
    System.debug(orgCurr);
    */

    //유저의 인포에 따라 달라짐.

    //Org의 Info를 반환
    String defaultCurrencyCode = [
      SELECT IsoCode
      FROM CurrencyType
      WHERE IsCorporate = TRUE
    ]
    .IsoCode;
    System.debug(defaultCurrencyCode);

    return defaultCurrencyCode;

    // ToDo : 기회의 통화 값에 따라서 해당 금액을 기준으로 변환해줘야한다.
    // 유저인포나 오그 인포를 가져오는게 아님.
  }
}
