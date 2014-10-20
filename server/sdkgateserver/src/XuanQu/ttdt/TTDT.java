package XuanQu.ttdt;

/**
 * @author banshuai
 * 
 */
public class TTDT {
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
//			XQClientAccount_Login al2 = (XQClientAccount_Login) aRequest;
//			aPlayer.setPID(al2.getPID());
//			aPlayer.setPUID(al2.getPUID());
//			aPlayer.setToken(al2.getToken());
//			aPlayer.setName(al2.getName());
//
//			XQServerAccountLoginMsg sal2 = al2.ToXQServerAccountLoginMsg();
//			// 支持多个gate服务，设置sessionId
//			sal2.setGateSession(aPlayer.getGateSessionID());
//			aPlayer.PlayerSendMessgeToServer(sal2, sal2.getType());
//		}
//	}
}
