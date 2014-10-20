package XuanQu.kingsoft.model;

/**
 * @author lijingyin
 * 
 */
public class SessionIdResponse {
//	private String memberId;
//	private String username;
//	private String nickname;
//	private String gender;
//	private String level;
//	private String avatar_url;
//	private String created_date;
//	private String token;
//	private String error_code;
//	private String error_msg;
	private Data data;
	private String msg;
	private String code;
	
	public SessionIdResponse(Data data,String msg,String i) {
		super();
		this.data=data;
		this.msg=msg;
		this.code=i;
	}

	public Data getData() {
		return data;
	}

	public void setData(Data data) {
		this.data = data;
	}

	public String getMsg() {
		return msg;
	}

	public void setMsg(String msg) {
		this.msg = msg;
	}
	
	public String getCode() {
		return code;
	}

	public void setCode(String code) {
		this.code = code;
	}



	private class Data{
		private String uid;

		public String getUid() {
			return uid;
		}

		public void setUid(String uid) {
			this.uid = uid;
		}
		
	}
}
