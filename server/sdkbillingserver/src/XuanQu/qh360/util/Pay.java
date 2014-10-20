package XuanQu.qh360.util;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Iterator;

import net.minidev.json.JSONObject;
import net.minidev.json.parser.JSONParser;
import net.minidev.json.parser.ParseException;
import XuanQu.qh360.Util;


public class Pay {

	private String VERIFY_URL = "";
	private static final String VERIFIED = "verified";
	private static final Boolean IGNORE_SSL = false;
	private String _appKey;
	private String _appSecret;
	private PayAppInterface _payApp;
	
	private String _errorMsg;

	public Pay(PayAppInterface payApp) {
		this._payApp = payApp;
		this._appKey = payApp.getAppKey();
		this._appSecret = payApp.getAppSecret();
		this.VERIFY_URL = payApp.getVerify_url();
	}

	/**
	 * 处理从360过来的支付订单通知请求
	 * @param params
	 * @return 
	 */
	public String processRequest(HashMap<String, String> params) {

		if (!_isValidRequest(params)) {
			if(!this._errorMsg.isEmpty())
			{
				return this._errorMsg;
			}
			return "invalid request ";
		}

//		if (!this._verifyOrder(params)) {
//			if(!this._errorMsg.isEmpty())
//			{
//				return this._errorMsg;
//			}
//			return "verify failed";
//		}

		// 订单处理在Lua做 zhm
//		if (this._payApp.isValidOrder(params)) {
//			this._payApp.processOrder(params);
//		}
		return "ok";
	}

	/**
	 * 向360服务器发起请求验证订单是否有效
	 * @param params
	 * @return Boolean 是否有效
	 */
	private Boolean _verifyOrder(HashMap<String, String> params) {
		String url = VERIFY_URL;

		HashMap<String, String> requestParams = new HashMap();
		requestParams.put("client_id", this._appKey);
		requestParams.put("client_secret", this._appSecret);

		String field;
		Iterator<String> iterator = params.keySet().iterator();
		while (iterator.hasNext()) {
			field = iterator.next();
			if (field.equals("gateway_flag") || field.equals("sign")) {
				continue;
			}
			requestParams.put(field, params.get(field));
		}

		String ret;
		
		try {
			ret = Util.requestUrl(url, requestParams, IGNORE_SSL);
		} catch (IOException e) {
			this._errorMsg = e.toString();
			return false;
		} catch (Exception e1) {
			this._errorMsg = e1.toString();
			return false;
		}

		JSONParser jsonParser = new JSONParser(JSONParser.DEFAULT_PERMISSIVE_MODE);
		JSONObject obj;
		try {
			obj = (JSONObject) jsonParser.parse(ret);
			
			Boolean verified =  obj.get("ret").equals(VERIFIED);
			if(!verified)
			{
				this._errorMsg = obj.get("ret").toString();
			}
			return verified;
		} catch (ParseException e) {
			this._errorMsg = e.toString();
			return false;
		}
	}

	/**
	 * 检查request完整性
	 * @param params
	 * @return Boolean
	 */
	private Boolean _isValidRequest(HashMap params) {

		String arrFields[] = {"app_key", "product_id", "amount", "app_uid",
			"order_id", "sign_type", "gateway_flag",
			"sign", "sign_return"
		};
		ArrayList fields = new ArrayList(Arrays.asList(arrFields));

		String key;
		String value;
		Iterator iterator = fields.iterator();
		while (iterator.hasNext()) {
			key = (String) iterator.next();
			value = (String) params.get(key);
			
			if (value == null || value.equals("")) {
				this._errorMsg = "error params";
				return false;
			}
		}
		
		if(!params.get("app_key").equals(this._appKey)){
			this._errorMsg = "not my order";
			return false;
		}
		
		String sign = Util.getSign(params, this._appSecret);
		String paramSign = (String) params.get("sign");
		if (!sign.equals(paramSign)) {
			this._errorMsg = "not match sign";
			return false;
		}
		
		return true;
	}
}
