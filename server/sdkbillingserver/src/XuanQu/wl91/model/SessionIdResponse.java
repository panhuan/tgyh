package XuanQu.wl91.model;

/**
 * @author banshuai
 *
 */
public class SessionIdResponse {
	private String ErrorCode;
	private String ErrorDesc;

	public SessionIdResponse(String errorCode, String errorDesc) {
		super();
		ErrorCode = errorCode;
		ErrorDesc = errorDesc;
	}

	public String getErrorCode() {
		return ErrorCode;
	}

	public void setErrorCode(String errorCode) {
		ErrorCode = errorCode;
	}

	public String getErrorDesc() {
		return ErrorDesc;
	}

	public void setErrorDesc(String errorDesc) {
		ErrorDesc = errorDesc;
	}
}
