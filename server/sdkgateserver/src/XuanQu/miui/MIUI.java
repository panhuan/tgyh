package XuanQu.miui;

import net.sf.json.JSONObject;
import net.sf.json.util.JSONTokener;
import XuanQu.miui.model.SessionIdResponse;

/**
 * @author banshuai
 * 
 */
public class MIUI {
	// sdk server检查session是否过期的接口地址
	private static String ServerUrl_CheckSession = "";
	// 主动查询订单状态
	private static String ServerUrl_QueryOrder = "";
	// 游戏合作商编号
	private static int AppId = 0;
	// 游戏合作商key
	private static String AppKey = "";

	public void Init() throws Exception {
		ServerUrl_CheckSession = Util.getConfig("ServerUrl_CheckSession");
		ServerUrl_QueryOrder = Util.getConfig("ServerUrl_QueryOrder");
		AppId = Integer.valueOf(Util.getConfig("AppId"));
		AppKey = Util.getConfig("AppKey");
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
//			String connectStr = "appId=" + AppId + "&session=" + session
//					+ "&uid=" + uid;
//			String signature = "";
//			try {
//				signature = HmacSHA1Encryption.HmacSHA1Encrypt(connectStr,
//						AppKey);
//			} catch (Exception e1) {
//				e1.printStackTrace();
//				System.out.println("签名错误");
//			}
//
//			String searchUrl = "appId=" + AppId;
//			searchUrl += "&session=" + session;
//			searchUrl += "&uid=" + uid;
//			searchUrl += "&signature=" + signature;
//			String url = ServerUrl_CheckSession + "?" + searchUrl;
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
//						resultJson.getString("errcode"), "");
//
//				if (sessionIdResponse != null
//						&& "200".equals(sessionIdResponse.getErrcode())) {
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
//						&& "1515".equals(sessionIdResponse.getErrcode())) {
//					tip = "appId错误";
//				} else if (sessionIdResponse != null
//						&& "1516".equals(sessionIdResponse.getErrcode())) {
//					tip = "uid错误";
//				} else if (sessionIdResponse != null
//						&& "1520".equals(sessionIdResponse.getErrcode())) {
//					tip = "session错误";
//				} else if (sessionIdResponse != null
//						&& "1525".equals(sessionIdResponse.getErrcode())) {
//					tip = "signature错误";
//				} else {
//					aPlayer.getSession().close(true);
//				}
//			} catch (Exception e) {
//				e.printStackTrace();
//			}
//		}
//	}

}
