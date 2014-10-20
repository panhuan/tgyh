package XuanQu.tongbutui;

import net.sf.json.JSONObject;
import net.sf.json.util.JSONTokener;

/**
 * @author banshuai
 * 
 */
public class TongBuTui {

	private String CheckUrl;

	public void Init() throws Exception {
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
//			String puid = aRequest.getPUID();
//			String username = aRequest.getName();
//			String url = CheckUrl + "k=" + token;
//
//			try {
//
//				String result = Util.doGet(url);
//				JSONTokener jsonParser = new JSONTokener(result);
//				// 此时还未读取任何json文本，直接读取就是一个JSONObject对象。
//				JSONObject resultJson = (JSONObject) jsonParser.nextValue();
//
//				String code = resultJson.getString("code");
//				
//				if ("1".equals(code)) {
//					
//					XQClientAccount_Login al2 = (XQClientAccount_Login) aRequest;
//					aPlayer.setPID(al2.getPID());
//					aPlayer.setPUID(puid);
//					aPlayer.setToken(token);
//					aPlayer.setName(username);
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
