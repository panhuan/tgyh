package XuanQu.baidu;

import net.sf.json.JSONObject;
import net.sf.json.util.JSONTokener;
import XuanQu.baidu.model.SessionIdResponse;

/**
 * @author banshuai
 * 
 */
public class BaiDu {
	// sdk server检查session是否过期的接口地址
	private static String ServerUrl_CheckSession = "";
	// 主动查询订单状态
	private static String ServerUrl_QueryOrder = "";
	// 游戏合作商编号
	private static int AppId = 0;
	// 游戏合作商key
	private static String AppKey = "";
	//游戏合作商secret
	private static String AppSecret = "";

	public void Init() throws Exception {
		ServerUrl_CheckSession = Util.getConfig("ServerUrl_CheckSession");
		ServerUrl_QueryOrder = Util.getConfig("ServerUrl_QueryOrder");
		AppId = Integer.valueOf(Util.getConfig("AppId"));
		AppKey = Util.getConfig("AppKey");
		AppSecret = Util.getConfig("AppSecret");
	}

	/**
	 * 检查用户登陆sessionId是否有效
	 * 
	 * @param aPlayer
	 * @param aRequest
	 */
//	public void checkSessionId(Player aPlayer, XQClientAccount_Login aRequest) {
//		if (aRequest != null && aPlayer != null) {
//			// 用户登录的SessionId
//			String session = aRequest.getToken();
//			// 用户的91Uin
//			String uid = aRequest.getPUID();
//
//			String connectStr = AppId + AppKey + uid + session + AppSecret;
//			
////			connectStr = connectStr.toLowerCase();
//			
//			String signature = Util.getMD5(connectStr);
//
//			String searchUrl = "appid=" + AppId;
//			searchUrl += "&appkey=" + AppKey;
//			searchUrl += "&uid=" + uid;
//			searchUrl += "&sessionid=" + session;
//			searchUrl += "&clientsecret=" + signature;
//			String url = ServerUrl_CheckSession + "?" + searchUrl;
//
//			try {
//				String result = Util.doGet(url);
//
//				JSONTokener jsonParser = new JSONTokener(result);
//				// 此时还未读取任何json文本，直接读取就是一个JSONObject对象。
//				JSONObject resultJson = (JSONObject) jsonParser.nextValue();
//				// 接下来的就是JSON对象的操作了
//
//				SessionIdResponse sessionIdResponse = new SessionIdResponse(
//						resultJson.getString("error_code"), "");
//				
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
//				} else {
//					aPlayer.getSession().close(true);
//				}
//			} catch (Exception e) {
//				e.printStackTrace();
//			}
//		}
//	}
}
