@isTest
public class DateTimeFormatControllerTest {
    static testmethod void getFormattedDatetimeTest(){
        DateTimeFormatController dt = New DateTimeFormatController();
        dt.getFormattedDatetime();
        dt.date_time = System.Now();
        dt.getFormattedDatetime();
        dt.defined_format = 'HH:ss';
        String dtf = dt.getFormattedDatetime();
        System.assertNotEquals('',''+ dtf,'Should not blank');
    }
}