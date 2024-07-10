public class CurrencyDataScheduler implements Schedulable {
  //오전 9시 1분에 데이터 가져오도록 스케줄링 되어있음.
  public void execute(SchedulableContext ctx) {
    GetTodayCurrencyInfo.updateCurrencyDataForOrg();
  }
}
