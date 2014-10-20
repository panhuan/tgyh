package XuanQu.baidu.model;

/**
 * 获取用户sessionId接口返回信息封装
 * 
 * @author banshuai
 * 
 */
public class SessionIdResponse {

	private String error_code;
	private String error_msg;

	public SessionIdResponse(String error_code, String error_msg) {
		super();
		this.error_code = error_code;
		this.error_msg = error_msg;
	}

	public String getError_code() {
		return error_code;
	}

	public void setError_code(String error_code) {
		this.error_code = error_code;
	}

	public String getError_msg() {
		return error_msg;
	}

	public void setError_msg(String error_msg) {
		this.error_msg = error_msg;
	}

}

