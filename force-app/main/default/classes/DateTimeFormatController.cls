public class DateTimeFormatController {
	public DateTime date_time { get; set; } 
	public String defined_format { get; set; }	
	public String getFormattedDatetime() {
		if (date_time == null) { 
			return ''; 
		} else { 
			if (defined_format == null) { 
				return date_time.format();
			} else { 
				return date_time.format(defined_format);
			}
		}
	}
}