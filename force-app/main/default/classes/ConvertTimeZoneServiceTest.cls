@isTest
public class ConvertTimeZoneServiceTest {
    @isTest
    public static void convertTimeZoneServiceTestMethod(){
        String sourceTimeZone = String.valueOf(Timezone.getTimeZone('America/Puerto_Rico'));
        String targetTimeZone = String.valueOf(Timezone.getTimeZone('America/Puerto_Rico'));
        Integer offset = ConvertTimeZoneService.getOffsetFromTimezone(Datetime.newInstance(2024, 5, 15, 10, 0, 0),sourceTimeZone);
        Integer correction = ConvertTimeZoneService.getOffsetTimeDiffrence(Datetime.newInstance(2024, 5, 15, 10, 0, 0),sourceTimeZone);
        Datetime targetDT = ConvertTimeZoneService.convertDateTimeToOtherTimeZone(Datetime.newInstance(2024, 5, 15, 10, 0, 0),sourceTimeZone,targetTimeZone);
        DateTime dtime = ConvertTimeZoneService.convertTimezoneWithDateTime(Date.newInstance(2024, 5, 15),sourceTimeZone,targetTimeZone);
        DateTime targetDTNew = ConvertTimeZoneService.convertTimezoneWithDateTime(Datetime.newInstance(2024, 5, 15, 10, 0, 0),targetTimeZone,targetTimeZone);
        Assert.areEqual(-240,offset,'Offset is not correct');
    }
}