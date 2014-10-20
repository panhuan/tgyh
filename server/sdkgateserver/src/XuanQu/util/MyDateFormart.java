package XuanQu.util;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

/**
 * @author handsomeban
 * 
 */
public class MyDateFormart {
	public static final Date strToDate(String str) {
		DateFormat format = DateFormat.getDateInstance();
		Date d = null;
		try {
			d = new Date(format.parse(str).getTime());
		} catch (ParseException e) {
			e.printStackTrace();
		}
		return d;
	}

	public static final String strToDate() {
		Calendar c = Calendar.getInstance();
		Date d = (Date) c.getTime();

		DateFormat format = DateFormat.getDateInstance();
		String newd = format.format(d);
//		System.out.println(newd.toString());
		return null;
	}

	public static final String getDate() {
		SimpleDateFormat df = new SimpleDateFormat("yyyyMMddHHmmss");
		return df.format(new Date());
	}

	public static final String getToDate() {
		SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		return df.format(new Date());
	}

	public static void main(String[] args) {
		Date date = new Date();
		String Data = String.valueOf(date.getDate());
		
//		System.out.println(Data);
	}

	// ��Ļ�ȡʱ�䷽��
	// ���������£�Mon Mar 12 17:40:00 CST 2007
	public static Date getUtilDate() {
		java.util.Date utildate = new java.util.Date();
		return utildate;
	}

	// ��ȡ�����ո�ʽ��ʱ��
	// ���������£�2007-03-12
	public static Date getSqlDate() {
		java.util.Date utildate = new java.util.Date();
		java.sql.Date date = new java.sql.Date(utildate.getTime());
		return date;
	}

	// ��ȡʱ�����ʽ��ʱ��
	// ���������£�17:41:21
	public static String getStringTime() {
		java.util.Date utildate = new java.util.Date();
		String str = DateFormat.getTimeInstance().format(utildate);

		return str;
	}

	// ��ȡʱ���
	// ���������£�1173692497326
	public static Long getTimeC() {
		long time = System.currentTimeMillis();
		return time;
	}

	// ��ָ����ʽ��ȡʱ��
	// ��ʽ���ʱ�����hh��ʾ��12Сʱ�ƣ�HH��ʾ��24Сʱ�ơ�MM�����Ǵ�д!
	// ���������£�2007��03��12��05:42:08
	public static String getFormatDate() {
		Date today = new Date();
		SimpleDateFormat f = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		String time = f.format(today);
		return time;
	}
	//��ȡ��ǰ���
	public static String getFormatDateToYear() {
		Date today = new Date();
		SimpleDateFormat f = new SimpleDateFormat("yyyy");
		String year = f.format(today);
		return year;
	}
	
	public static String getFormatDateToMonth(){
		Date today = new Date();
		SimpleDateFormat f = new SimpleDateFormat("MM");
		String month = f.format(today);
		return month;
	}
	
	public static String getFormatDateToDay(){
		Date today = new Date();
		SimpleDateFormat f = new SimpleDateFormat("dd");
		String day = f.format(today);
		return day;
	}
	
	public static String getFormatDateToYMD(){
		Date today = new Date();
		SimpleDateFormat f = new SimpleDateFormat("yyyyMMdd");
		String day = f.format(today);
		return day;
	}
	
	public static String getFormatDateToYM(){
		Date today = new Date();
		SimpleDateFormat f = new SimpleDateFormat("yyyyMM");
		String day = f.format(today);
		return day;
	}
	
	public static String getFormatDateTo_YMD(){
		Date today = new Date();
		SimpleDateFormat f = new SimpleDateFormat("yyyy-MM-dd");
		String date = f.format(today);
		return date;
	}
}