public with sharing class AccountController {
    @AuraEnabled(cacheable = true) // @AuraEnabled 데코레이터를 사용해야 LWC 컴포넌트에서 wire로 값을 가져올 수 있다. 
    //cacheable true 옵션은 데이터가 캐시에서 오므로 
    public static List<Account> getHighRevenueAccountRecords(Integer count){
        try {
            return [SELECT Id, Name, AnnualRevenue FROM Account ORDER BY AnnualRevenue DESC NULLS LAST LIMIT :count];
        } catch (Exception e) {
         throw new AuraHandledException(e.getMessage());   
        }
    }
}