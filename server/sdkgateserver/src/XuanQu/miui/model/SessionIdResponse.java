package XuanQu.miui.model;

/**
 * 获取用户sessionId接口返回信息封装
 * @author banshuai
 *
 */
public class SessionIdResponse {

	private String errcode;
	private String errMsg;

	public SessionIdResponse(String errcode, String errMsg) {
		super();
		this.errcode = errcode;
		this.errMsg = errMsg;
	}

	public String getErrcode() {
		return errcode;
	}

	public void setErrcode(String errcode) {
		this.errcode = errcode;
	}

	public String getErrMsg() {
		return errMsg;
	}

	public void setErrMsg(String errMsg) {
		this.errMsg = errMsg;
	}

}
