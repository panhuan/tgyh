package XuanQu.kuaiyong;

import net.sf.json.JSONObject;
import net.sf.json.util.JSONTokener;

/**
 * @author banshuai
 * 
 */
public class KuaiYong {

	private String appId;

	private String appKey;

	private String CheckUrl;

	public void Init() throws Exception {
		appId = Util.getConfig("AppId");
		appKey = Util.getConfig("AppKey");
		CheckUrl = Util.getConfig("CheckUrl");
	}

	/**
	 * 检查用户登陆sessionId是否有效
	 * 
	 * @param aPlayer
	 * @param aRequest
	 */

//	public void checkSessionId(Player aPlayer, XQClientAccount_Login aRequest) {
//		if (aRequest != null && aPlayer != null) {
//			String token = aRequest.getToken();
//			
//			String sign = Util.getMD5(appKey + token).toLowerCase();
//
//			String url = CheckUrl + "tokenKey=" + token + "&sign=" + sign;
//
//			try {
//
//				String result = Util.doGet(url);
//				JSONTokener jsonParser = new JSONTokener(result);
//				// 此时还未读取任何json文本，直接读取就是一个JSONObject对象。
//				JSONObject resultJson = (JSONObject) jsonParser.nextValue();
//
//				String code = resultJson.getString("code");
//				String data = resultJson.getString("data");
//				String guid = "";
//				String username = "";
//				if ("0".equals(code)) {
//					JSONTokener jsonParser_data = new JSONTokener(data);
//					JSONObject resultJson_data = (JSONObject) jsonParser_data.nextValue();
//					guid = resultJson_data.getString("guid");
//
//					username = resultJson_data.getString("username");
//					
//					XQClientAccount_Login al2 = (XQClientAccount_Login) aRequest;
//					aPlayer.setPID(al2.getPID());
//					aPlayer.setPUID(guid);
//					aPlayer.setToken(token);
//					aPlayer.setName(username);
//					
//					al2.setPUID(guid);
//
//					XQServerAccountLoginMsg sal2 = al2
//							.ToXQServerAccountLoginMsg();
//					// 支持多个gate服务，设置sessionId
//					sal2.setGateSession(aPlayer.getGateSessionID());
//					aPlayer.PlayerSendMessgeToServer(sal2, sal2.getType());
//				}
//			} catch (Exception e) {
//				e.printStackTrace();
//			}
//		}
//	}
}
