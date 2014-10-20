package XuanQu.sy37;

import net.sf.json.JSONObject;

public class Sy37 {

	public void Init() throws Exception {
	}

	/**
	 * 检查用户登陆sessionId是否有效
	 * 
	 * @param aPlayer
	 * @param aRequest
	 */

//	public void checkSessionId(Player aPlayer, XQClientAccount_Login aRequest) {
//		if (aRequest != null && aPlayer != null) {
//
//			try {
//				int pid = aRequest.getPID();
//				String puid = aRequest.getPUID();
//				String name = aRequest.getName();
//				String token = aRequest.getToken();
//				String sign = MD5.md5Digest(MD5.md5Digest(Util
//						.getConfig("AppKey") + "_" + token));
//				String url = Util.getConfig("ServerUrl_CheckSession") + "?"
//						+ "sign=" + sign + "&token=" + token + "&app_id="
//						+ Util.getConfig("AppId");
//				String msg = Util.doGet(url);
//				JSONObject jsonObject = JSONObject.fromObject(msg);
//				String state = jsonObject.getString("state");
//				if ("1".equals(state)) {
//					XQClientAccount_Login al2 = (XQClientAccount_Login) aRequest;
//					aPlayer.setPID(al2.getPID());
//					aPlayer.setPUID(al2.getPUID());
//					aPlayer.setToken(token);
//					aPlayer.setName(al2.getName());
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
