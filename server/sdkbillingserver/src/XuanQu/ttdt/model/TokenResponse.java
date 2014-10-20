package XuanQu.ttdt.model;

/**
 * @author banshuai
 * 
 */
public class TokenResponse {
	private int code;
	private String msg;
	private TokenResponseData tokenResponseData;

	public int getCode() {
		return code;
	}

	public void setCode(int code) {
		this.code = code;
	}

	public String getMsg() {
		return msg;
	}

	public void setMsg(String msg) {
		this.msg = msg;
	}

	public TokenResponseData getTokenResponseData() {
		return tokenResponseData;
	}

	public void setTokenResponseData(TokenResponseData tokenResponseData) {
		this.tokenResponseData = tokenResponseData;
	}

	public class TokenResponseData {
		private String auth_token;
		private int expires_in;

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
	}
}
