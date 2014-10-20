/**
 * 
 */
package XuanQu.qh360.util;

import java.util.HashMap;

public class QException extends Exception {

	public static final String CODE_NET_ERROR = "999";
	public static final String CODE_JSON_ERROR = "998";
	public static final String CODE_NO_APPKEY = "997";
	public static final String CODE_NO_SECRET = "996";
	public static final String CODE_BAD_PARAM = "995";
	private static final String CODE_BAD_APPKEY_OR_SECRET = "4000203";
	private static HashMap<String, String> _messageMap;
	private String _code;
	private String _message;

	public QException(String code, String message) {

		QException._initMessageMap();

		if (code.equals(CODE_BAD_APPKEY_OR_SECRET)) {
			message = "";
		}
		String msgInConf = _messageMap.get(code);
		if (msgInConf!=null && !msgInConf.isEmpty()) {
			message = msgInConf + message;
		}

		this._code = code;
		this._message = message;
	}

	private static void _initMessageMap() {
		if (QException._messageMap!=null && !QException._messageMap.isEmpty()) {
			return;
		}

		QException._messageMap = new HashMap<String, String>();
		QException._messageMap.put(CODE_NET_ERROR, "访问远程接口失败，请检查网络。链接：");
		QException._messageMap.put(CODE_JSON_ERROR, "JSON解析失败，原始串：");
		QException._messageMap.put(CODE_NO_APPKEY, "请填写app_key。");
		QException._messageMap.put(CODE_NO_SECRET, "请填写app_secret。");
		QException._messageMap.put(CODE_BAD_PARAM, "请检查传入参数。");
		QException._messageMap.put(CODE_BAD_APPKEY_OR_SECRET, "app_key或者app_secret不正确,请检查。");
	}

	public String getCode() {
		return this._code;
	}

	@Override
	public String getMessage() {
		return this._message;
	}
}
