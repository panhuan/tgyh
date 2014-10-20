package XuanQu.kingsoft;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;

import net.sf.json.JSONObject;
import net.sf.json.util.JSONTokener;
import XuanQu.kingsoft.model.SessionIdResponse;



/**
 * @author lijingyin
 * 
 */
public class KingSoft {
	
	private String appId;

	private String appKey;

	private String serverUrl;
	
	private String paymentKey;
	
	public void Init() throws Exception {
		
		serverUrl = Util.getConfig("ServerUrl");
		appId = Util.getConfig("AppId");
		appKey = Util.getConfig("AppKey");
//		paymentKey = Util.getConfig("PaymengKey");
		
	}
	
//	public String getPaymentKey(){
//		return paymentKey;
//	}
	
	/**
	 * 检查用户登陆sessionId是否有效
	 * 
	 * @param aPlayer
	 * @param aRequest
	 */

//	public void checkSessionId(Player aPlayer, XQClientAccount_Login aRequest) {
//		if (aRequest != null && aPlayer != null) {
////			// 用户登录的SessionId
//			String token = aRequest.getToken();
//			
//			String pfkey = "lovedance_kingsoft";
//			
//			String sign = "";			
//			String _mutk = "";
//			String _supplier_id = "";
//			String _time = "";
//			String _client_ip = aRequest.getName();
//			try {
//				_mutk = URLEncoder.encode(token, "utf-8");
//				_supplier_id = URLEncoder.encode(appId, "utf-8");
////				_client_ip = URLEncoder.encode(aRequest.getName(), "utf-8");
//			} catch (UnsupportedEncodingException e1) {
//				e1.printStackTrace();
//			}
////
//			String searchUrl = "client_ip=" + _client_ip;
//			searchUrl += "&mutk=" + _mutk;
//			searchUrl += "&supplier_id=" + _supplier_id;
//			searchUrl += "&time=" + System.currentTimeMillis();
//			
//			String strSign = searchUrl + appKey;
//
//			sign = Util.getMD5(strSign);
//			
//			searchUrl += "&sign=" + sign;
//			String url = serverUrl + "?" + searchUrl;
//
//			try {
////				String tip = "";
//				String result = Util.doGet(url);
//
//				JSONTokener jsonParser = new JSONTokener(result);
//				// 此时还未读取任何json文本，直接读取就是一个JSONObject对象。
//				JSONObject resultJson = (JSONObject) jsonParser.nextValue();
//				// 接下来的就是JSON对象的操作了
//
//				SessionIdResponse sessionIdResponse = new SessionIdResponse(null, null, resultJson.getString("code"));
//
//				if (sessionIdResponse != null
//						&& "1".equals(sessionIdResponse.getCode())) {
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
//						&& "2".equals(sessionIdResponse.getCode())) {
//					//用户未登陆
////					System.out.println("用户未登录！");
//				}
//			} catch (Exception e) {
//				e.printStackTrace();
//			}
//		}
//	}
}
