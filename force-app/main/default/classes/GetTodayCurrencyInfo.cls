public with sharing class GetTodayCurrencyInfo {
  private static String authkey = 'c1717c7597e773c596c52064';
  private static List<String> orgCurrencies; //org의 활성화된 currency의 code 목록을 저장

  public class CurrencyInfo {
    public String result;
    public Long time_last_update_unix;
    public Long time_next_update_unix;
    public String base_code;
    public Map<String, Decimal> conversion_rates;
  }

  public static List<String> setOrgCurrencies() {
    // 현재 org에서 활성화된 CurrencyType들을 모두 가져온다.
    List<CurrencyType> currencyTypes = OrgCurrency.getOrgCurrencies();
    List<String> orgCurrencies = new List<String>();

    // 각 CurrencyType 객체에서 IsoCode를 추출하여 리스트에 추가한다.
    for (CurrencyType c : currencyTypes) {
      orgCurrencies.add(c.IsoCode);
    }

    return orgCurrencies;
  }

  public static void updateCurrencyDataForOrg() {
    // 현재 org에서 활성화된 통화 코드들을 가져온다.
    List<String> orgCurrencies = setOrgCurrencies();

    // 이미 존재하는 CurrencyData__c 레코드들을 Map으로 가져온다 (IsoCode를 key로 사용).
    Map<String, CurrencyData__c> existingCurrenciesMap = new Map<String, CurrencyData__c>();
    List<CurrencyData__c> existingCurrencies = [
      SELECT Id, base_code__c
      FROM CurrencyData__c
      WHERE
        base_code__c IN :orgCurrencies
        AND DAY_ONLY(time_last_update_unix__c) = :Date.today()
    ];
    for (CurrencyData__c cur : existingCurrencies) {
      existingCurrenciesMap.put(cur.base_code__c, cur);
    }

    List<CurrencyData__c> currenciesToUpsert = new List<CurrencyData__c>();

    // 각 활성화된 통화 코드에 대해 데이터를 업데이트한다.
    for (String currencyCode : orgCurrencies) {
      if (!existingCurrenciesMap.containsKey(currencyCode)) {
        // 기존에 캐시된 데이터가 없으면 API 호출하여 데이터 가져오기
        CurrencyData__c newCurrencyData = fetchAndSaveCurrencyData(
          currencyCode
        );
        if (newCurrencyData != null) {
          currenciesToUpsert.add(newCurrencyData);
        }
      }
    }

    // 업서트 실행
    if (!currenciesToUpsert.isEmpty()) {
      System.debug('업서트 진행');
      upsert currenciesToUpsert;
    }
  }

  //api 호출 후 값 리턴하는 코드
  private static CurrencyData__c fetchAndSaveCurrencyData(String baseCurrency) {
    Http h = new Http();
    HttpRequest req = new HttpRequest();
    req.setEndpoint(
      'https://v6.exchangerate-api.com/v6/' +
        authkey +
        '/latest/' +
        baseCurrency
    );
    req.setMethod('GET');

    try {
      HttpResponse res = h.send(req);
      Integer statusCode = res.getStatusCode();
      if (statusCode == 200) {
        String responseBody = res.getBody();

        // 응답 데이터를 객체로 변환
        CurrencyInfo currencyInfo = (CurrencyInfo) JSON.deserialize(
          responseBody,
          CurrencyInfo.class
        );

        // CurrencyData__c 객체 생성 및 값 설정
        CurrencyData__c newCache = new CurrencyData__c();
        newCache.base_code__c = currencyInfo.base_code;
        newCache.time_last_update_unix__c = DateTime.newInstance(
          currencyInfo.time_last_update_unix * 1000
        );
        newCache.time_next_update_unix__c = DateTime.newInstance(
          currencyInfo.time_next_update_unix * 1000
        );
        newCache.conversion_rates__c = JSON.serialize(
          currencyInfo.conversion_rates
        );
        newCache.LastUpdated__c = DateTime.now();
        newCache.Response__c = responseBody;
        newCache.result__c = currencyInfo.result;

        return newCache;
      } else {
        System.debug('HTTP Error Code: ' + statusCode);
        System.debug('HTTP Error Message: ' + res.getStatus());
        return null;
      }
    } catch (Exception e) {
      System.debug('실패: ' + e.getMessage());
      return null;
    }
  }

  @AuraEnabled(cacheable=true)
  public static Map<String, Object> getConversionRates(String baseCurrency) {
    Map<String, Object> resultMap = new Map<String, Object>();

    // 오늘 날짜
    Date today = Date.today();

    // 오늘과 일치하는 데이터가 있는지 확인
    List<CurrencyData__c> currencyDataList = [
      SELECT base_code__c, conversion_rates__c, time_last_update_unix__c
      FROM CurrencyData__c
      WHERE
        base_code__c = :baseCurrency
        AND DAY_ONLY(time_last_update_unix__c) = :today
    ];

    if (!currencyDataList.isEmpty()) {
      // 오늘 데이터가 있으면 그것을 사용
      CurrencyData__c currencyData = currencyDataList[0];
      Map<String, Object> conversionRates = (Map<String, Object>) JSON.deserializeUntyped(
        currencyData.conversion_rates__c
      );
      resultMap.put('conversionRates', conversionRates);
      resultMap.put('lastUpdatedTime', currencyData.time_last_update_unix__c);
    } else {
      // 오늘 데이터가 없으면 어제 데이터를 가져옴
      List<CurrencyData__c> yesterdayCurrencyDataList = [
        SELECT base_code__c, conversion_rates__c, time_last_update_unix__c
        FROM CurrencyData__c
        WHERE
          base_code__c = :baseCurrency
          AND DAY_ONLY(time_last_update_unix__c) = :today.addDays(-1)
      ];
      if (!yesterdayCurrencyDataList.isEmpty()) {
        CurrencyData__c currencyData = yesterdayCurrencyDataList[0];
        Map<String, Object> conversionRates = (Map<String, Object>) JSON.deserializeUntyped(
          currencyData.conversion_rates__c
        );
        resultMap.put('conversionRates', conversionRates);
        resultMap.put('lastUpdatedTime', currencyData.time_last_update_unix__c);
      }
    }

    System.debug(JSON.serializePretty(resultMap));
    return resultMap;
  }
}
