package XuanQu.wl91;

import net.sf.json.JSONObject;
import net.sf.json.util.JSONTokener;
import XuanQu.wl91.model.SessionIdResponse;

/**
 * @author banshuai
 *
 */
public class Wl91 {
	// sdk server的接口地址
	private static String ServerUrl = "";
	// 游戏合作商编号
	private static int AppId = 0;
	// 游戏合作商key
	private static String AppKey = "";
	
	private static int AppId_Android = 0;
	private static String AppKey_Android = "";
	private static int AppId_IOS = 0;
	private static String AppKey_IOS = "";

	public void Init() throws Exception {
		ServerUrl = Util.getConfig("ServerUrl");
		AppId_IOS = Integer.valueOf(Util.getConfig("AppId"));
		AppKey_IOS = Util.getConfig("AppKey");
		AppId_Android = Integer.valueOf(Util.getConfig("AppId_Android"));
		AppKey_Android = Util.getConfig("AppKey_Android");
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
//			String userName = aRequest.getName();
//			
//			if("Android813".equals(userName)) {
//				AppId = AppId_Android;
//				AppKey = AppKey_Android;
//			} else {
//				AppId = AppId_IOS;
//				AppKey = AppKey_IOS;
//			}
//			
//			// 用户登录的SessionId
//			String SessionId = aRequest.getToken();
//			// 用户的91Uin
//			String Uin = aRequest.getPUID();
//			// 91提供接口编号（Act=1，支付购买结果；Act=2发送用户动态；Act=4检查用户登录SessionId
//			String Act = "4";
//			// 参数值与AppKey的MD5值.此方法在java上不适用：String.format("{0}{1}{2}{3}{4}",
//			// AppId,Act, Uin, SessionId, AppKey)
//			String connectStr = AppId + Act + Uin + SessionId + AppKey;
//			String Sign = Util.getMD5(connectStr);
//
//			String searchUrl = "AppId=" + AppId;
//			searchUrl += "&Act=" + Act;
//			searchUrl += "&Uin=" + Uin;
//			searchUrl += "&Sign=" + Sign;
//			searchUrl += "&SessionID=" + SessionId;
//			String url = ServerUrl + "?" + searchUrl;
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
//						resultJson.getString("ErrorCode"),
//						resultJson.getString("ErrorDesc"));
//				
//				if (sessionIdResponse != null
//						&& "1".equals(sessionIdResponse.getErrorCode())) {
//					XQClientAccount_Login al2 = (XQClientAccount_Login) aRequest;
//					aPlayer.setPID(al2.getPID());
//					aPlayer.setPUID(al2.getPUID());
//					aPlayer.setToken(al2.getToken());
//					aPlayer.setName(al2.getName());
//					//新增sessionId
////					aPlayer.setSesionID(Long.parseLong(al2.getToken()));
//
//					XQServerAccountLoginMsg sal2 = al2
//							.ToXQServerAccountLoginMsg();
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
