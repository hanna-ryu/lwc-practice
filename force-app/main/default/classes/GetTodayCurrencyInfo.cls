public with sharing class GetTodayCurrencyInfo {
  private static String authkey = 'c1717c7597e773c596c52064';
  private static String baseCurrency = 'KRW'; // ToDo : 이후 기회 -> LWC picklist에서 정보 가져와야함.

  public class CurrencyInfo {
    public String result;
    public Long time_last_update_unix;
    public Long time_next_update_unix;
    public String base_code;
    public Map<String, Decimal> conversion_rates;
  }

  @AuraEnabled(cacheable=true)
  public static CurrencyData__c getCurrencyAPIInfo(String baseCurrency) {
    // Custom Object에서 캐시된 데이터 가져오기
    List<CurrencyData__c> cacheList = [
      SELECT
        Id,
        External_Id__c,
        base_code__c,
        time_last_update_unix__c,
        time_next_update_unix__c,
        conversion_rates__c
      FROM CurrencyData__c
      WHERE
        base_code__c = :baseCurrency
        AND DAY_ONLY(time_last_update_unix__c) = :Date.today()
    ];

    CurrencyData__c cache;

    if (!cacheList.isEmpty()) {
      cache = cacheList[0];
    }

    if (cache != null) {
      // 캐시된 데이터 반환
      return cache;
    }

    System.debug('데이터 없음 - 새로 api 호출');
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
        System.debug('Response Body: ' + responseBody);

        // 응답 데이터를 객체로 변환
        CurrencyInfo currencyInfo = (CurrencyInfo) JSON.deserialize(
          responseBody,
          CurrencyInfo.class
        );

        // 새로운 CurrencyData__c 객체 생성 및 값 설정
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

        // 캐시 데이터 업서트
        upsert newCache;

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
  public static Map<String, String> getConversionRates(String baseCurrency) {
    CurrencyData__c data = getCurrencyAPIInfo(baseCurrency);
    Map<String, String> resultMap = new Map<String, String>();
    if (data != null && data.conversion_rates__c != null) {
      Map<String, Object> conversionRates = (Map<String, Object>) JSON.deserializeUntyped(
        data.conversion_rates__c
      );
      for (String key : conversionRates.keySet()) {
        resultMap.put(key, String.valueOf(conversionRates.get(key)));
      }
    }
    return resultMap;
  }
}
