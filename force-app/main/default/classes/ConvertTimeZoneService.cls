public class ConvertTimeZoneService{
    public static string EST='America/New_York';
    
    public static Integer getOffsetFromTimezone(DateTime dttime, String timezoneName){
        TimeZone tz = Timezone.getTimeZone(timezoneName);
        Integer offset=tz.getOffset(dttime);
        offset = offset / (1000 * 60);
        return offset;
    }

    //Get offset date/time diffrence
    public static Integer getOffsetTimeDiffrence(DateTime dttime, String targetTimezone){
        TimeZone tz = UserInfo.getTimeZone();
        Integer offset=tz.getOffset(dttime);

        // target Timezone.
        TimeZone targetTZ = Timezone.getTimeZone(targetTimezone);
        Integer offsetTotargetTZ = targetTZ.getOffset(dttime);
       	Integer correction = offsetTotargetTZ- offset;
    
        return correction;
    }

    //Convert Any time to other timezone
    public static DateTime convertDateTimeToOtherTimeZone(DateTime dttime, string sourceTimezone, string targetTimezone){
        TimeZone tz = Timezone.getTimeZone(sourceTimezone);
        //System.debug('Display name: ' + tz.getDisplayName());
        //System.debug('ID: ' + tz.getID());
        
        Integer offset=tz.getOffset(dttime);
        //System.debug('Offset: ' + offset);
        
        // target Timezone.
        TimeZone targetTZ = Timezone.getTimeZone(targetTimezone);
        //System.debug('Display name: ' + targetTZ.getDisplayName());
        Integer offsetTotargetTZ = targetTZ.getOffset(dttime);
       	Integer correction = offsetTotargetTZ- offset;
    
        DateTime targetDT = dttime.addMinutes(correction / (1000 * 60));
        //System.debug(targetDT);
        return targetDT;
        //return Time.newInstance(targetDT.hour(), targetDT.minute(), targetDT.second(), targetDT.millisecond());
    }

    // Date
    public static DateTime convertTimezoneWithDateTime(Date dt, String sourceTimezone, String targetTimezone){
        Datetime dtime = dt;
        dtime = convertTimezoneWithDateTime(dtime, sourceTimezone, targetTimezone);
        return dtime;
    }

    // DateTime
    public static DateTime convertTimezoneWithDateTime(DateTime dttime, String sourceTimezone, String targetTimezone){
        TimeZone tz = Timezone.getTimeZone(sourceTimezone);
        Integer offset=tz.getOffset(dttime);
        TimeZone targetTZ = Timezone.getTimeZone(targetTimezone);
        Integer offsetTotargetTZ = targetTZ.getOffset(dttime);
       	Integer correction = offsetTotargetTZ- offset;
        DateTime targetDT = dttime.addMinutes(correction / (1000 * 60));
        return targetDT;
    }
    
 }