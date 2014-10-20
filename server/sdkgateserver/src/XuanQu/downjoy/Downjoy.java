package XuanQu.downjoy;

import net.sf.json.JSONObject;
import net.sf.json.util.JSONTokener;
import XuanQu.downjoy.model.SessionIdResponse;

public class Downjoy {

	private String appId;

	private String appKey;

	private String serverUrl;
	
	private String paymentKey;

	public void Init() throws Exception {
		serverUrl = Util.getConfig("ServerUrl");
		appId = Util.getConfig("AppId");
		appKey = Util.getConfig("AppKey");
		paymentKey = Util.getConfig("PaymengKey");
	}
	
	public String getPaymentKey(){
		return paymentKey;
	}

//	public void checkSessionId(Player aPlayer, XQClientAccount_Login aRequest) {
//		if (aRequest != null && aPlayer != null) {
//			// 用户登录的SessionId
//			String token = aRequest.getToken();
//			// 用户的mid
//			String mid = aRequest.getPUID();
//
//			String connectStr = token + "|" + appKey;
//			String signature = "";
//			signature = Util.getMD5(connectStr);
//
//			String searchUrl = "app_id=" + appId;
//			searchUrl += "&mid=" + mid;
//			searchUrl += "&token=" + token;
//			searchUrl += "&sig=" + signature;
//			String url = serverUrl + "?" + searchUrl;
//
//			try {
//				String tip = "";
//				String result = Util.doGet(url);
//
//				JSONTokener jsonParser = new JSONTokener(result);
//				// 此时还未读取任何json文本，直接读取就是一个JSONObject对象。
//				JSONObject resultJson = (JSONObject) jsonParser.nextValue();
//				// 接下来的就是JSON对象的操作了
//
//				SessionIdResponse sessionIdResponse = new SessionIdResponse(
//						"", "", "", "", "", "",
//						"", "", resultJson.getString("error_code"), "");
//
//				if (sessionIdResponse != null
//						&& "0".equals(sessionIdResponse.getError_code())) {
//					XQClientAccount_Login al2 = (XQClientAccount_Login) aRequest;
//					aPlayer.setPID(al2.getPID());
//					aPlayer.setPUID(al2.getPUID());
//					aPlayer.setToken(al2.getToken());
//					aPlayer.setName(al2.getName());
//
//					XQServerAccountLoginMsg sal2 = al2
//							.ToXQServerAccountLoginMsg();
//					// 支持多个gate服务，设置sessionId
//					sal2.setGateSession(aPlayer.getGateSessionID());
//					aPlayer.PlayerSendMessgeToServer(sal2, sal2.getType());
//				} else if (sessionIdResponse != null
//						&& "211".equals(sessionIdResponse.getError_code())) {
//					tip = "app_key错误";
//				}
//			} catch (Exception e) {
//				e.printStackTrace();
//			}
//		}
//	}
}
