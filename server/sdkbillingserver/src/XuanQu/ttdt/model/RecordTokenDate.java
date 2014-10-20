package XuanQu.ttdt.model;

import java.util.Date;

/**
 * @author banshuai
 * 
 */
public class RecordTokenDate {
	private String auth_token;
	private int expires_in;
	private Date recode_date;

	public String getAuth_token() {
		return auth_token;
	}

	public void setAuth_token(String auth_token) {
		this.auth_token = auth_token;
	}

	public int getExpires_in() {
		return expires_in;
	}

	public void setExpires_in(int expires_in) {
		this.expires_in = expires_in;
	}

	public Date getRecode_ate() {
		return recode_date;
	}

	public void setRecode_date(Date recode_date) {
		this.recode_date = recode_date;
	}

}
