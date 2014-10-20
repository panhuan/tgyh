/**
 * 
 */
package XuanQu.qh360.util;

import java.io.IOException;
import java.util.HashMap;
import java.util.logging.Logger;

import net.minidev.json.JSONObject;
import net.minidev.json.parser.JSONParser;
import net.minidev.json.parser.ParseException;
import XuanQu.qh360.Util;

public class QOAuth2 {

	private String client_id = ""; // api key
	private String client_secret = ""; // app secret
	// Set up the API root URL.
	private String host = "";
	private String serverUrl_CheckSession = "";
	private String scope_basic = "";
	private String redirect_uri = "";

	public QOAuth2(String client_id, String client_secret,
			String serverUrl_CheckSession, String redirect_uri,
			String scope_basic, String host) throws QException {
		if (client_id.isEmpty()) {
			throw new QException(QException.CODE_NO_APPKEY, "");
		}
		if (client_secret.isEmpty()) {
			throw new QException(QException.CODE_NO_SECRET, "");
		}

		this.client_id = client_id;
		this.client_secret = client_secret;
		this.serverUrl_CheckSession = serverUrl_CheckSession;
		this.redirect_uri = redirect_uri;
		this.host = host;
		this.scope_basic = scope_basic;
	}

	/**
	 * 通过code获得用户信息和token信息(包括access_token, refresh_token)
	 * 
	 * @param code
	 * @return
	 * @throws QException
	 */
	public HashMap<String, HashMap<String, Object>> getInfoByCode(String code)
			throws QException {
		if (code == null) {
			throw new QException(QException.CODE_BAD_PARAM, "需要传code");
		}
		HashMap<String, Object> token = this.getAccessTokenByCode(code, null);
		HashMap<String, Object> user = this.userMe(token.get("access_token")
				.toString());

		HashMap<String, HashMap<String, Object>> ret = new HashMap();
		ret.put("token", token);
		ret.put("user", user);
		return ret;
	}

	/**
	 * 通过code换取token(包括access token和 refresh token)
	 * 
	 * @param code
	 * @param redirectUri
	 * @return
	 * @throws QException
	 */
	public HashMap<String, Object> getAccessTokenByCode(String code,
			String redirectUri) throws QException {
		if (redirectUri == null || redirectUri.isEmpty()) {
			redirectUri = redirect_uri;
		}

		if (code == null) {
			throw new QException(QException.CODE_BAD_PARAM, "需要传code");
		}

		HashMap<String, String> params = new HashMap<String, String>();
		params.put("grant_type", "authorization_code");
		params.put("code", code);
		params.put("client_id", this.client_id);
		params.put("client_secret", this.client_secret);
		params.put("redirect_uri", redirectUri);
		params.put("scope", scope_basic);
		return this._request(serverUrl_CheckSession, params);
	}

	/**
	 * 通过access token
	 * 
	 * @param tokenStr
	 * @return
	 * @throws QException
	 */
	public HashMap<String, Object> userMe(String tokenStr) throws QException {
		if (tokenStr == null) {
			throw new QException(QException.CODE_BAD_PARAM, "需要传入token");
		}
		HashMap<String, String> params = new HashMap<String, String>();
		params.put("access_token", tokenStr);
		return this._request(host + "/user/me.json", params);
	}

	/**
	 * 通过refreshToken刷新得到新的token信息(包括新的access_token和refresh_token)
	 * 
	 * @param refreshToken
	 * @return
	 * @throws QException
	 */
	public HashMap<String, Object> getAccessTokenByRefreshToken(
			String refreshToken) throws QException {
		if (refreshToken == null) {
			throw new QException(QException.CODE_BAD_PARAM, "需要传入refresh_token");
		}
		HashMap<String, String> data = new HashMap();
		data.put("grant_type", "refresh_token");
		data.put("refresh_token", refreshToken);
		data.put("client_id", this.client_id);
		data.put("client_secret", this.client_secret);
		data.put("scope", scope_basic);
		return this._request(serverUrl_CheckSession, data);
	}

	/**
	 * 查询token信息(app_key 和 360用户id)
	 * 
	 * @param tokenStr
	 *            access_token
	 * @return
	 * @throws QException
	 */
	public HashMap<String, Object> getTokenInfo(String tokenStr)
			throws QException {
		if (tokenStr == null) {
			throw new QException(QException.CODE_BAD_PARAM, "需要传入token");
		}
		HashMap<String, String> params = new HashMap<String, String>();
		params.put("access_token", tokenStr);
		return this._request(host + "/oauth2/get_token_info.json", params);
	}

	/**
	 * 向360服务器发送请求
	 * 
	 * @param url
	 *            请求地址
	 * @param params
	 *            请求参数
	 * @return HashMap 请求结果
	 * @throws QException
	 */
	private HashMap<String, Object> _request(String url,
			HashMap<String, String> params) throws QException {

		Logger log = Logger.getLogger("lavasoft");

		String fullUrl = url + "?" + Util.httpBuildQuery(params);
//		log.info(fullUrl);
		String jsonStr;
		try {
			jsonStr = Util.requestUrl(url, params, true);
		} catch (IOException e) {
			throw new QException(QException.CODE_NET_ERROR, fullUrl);
		}

		if (jsonStr.isEmpty()) {
			throw new QException(QException.CODE_NET_ERROR, fullUrl);
		}

		JSONParser jsonParser = new JSONParser(
				JSONParser.DEFAULT_PERMISSIVE_MODE);
		JSONObject obj;
		try {
			obj = (JSONObject) jsonParser.parse(jsonStr);
		} catch (ParseException e) {
			throw new QException(QException.CODE_JSON_ERROR, jsonStr);
		} catch (Exception e1) {
			throw new QException(QException.CODE_JSON_ERROR, jsonStr);
		}

//		log.info(obj.toString());
		String errorCode = (String) obj.get("error_code");
		if (errorCode != null && !errorCode.isEmpty()) {
			String err = (String) obj.get("error");
			throw new QException(errorCode, err);
		}
		return obj;
	}
}
