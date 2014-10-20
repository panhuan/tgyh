package XuanQu.xunlei;

import net.sf.json.JSONObject;
import XuanQu.lenovo.Util;

public class XunLei {
	private String checkUrl;

	private String appKey;
	
	public void Init() throws Exception {
		checkUrl = Util.getConfig("checkUrl");
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
//			try{
//					int pid=aRequest.getPID();
//					String puid=aRequest.getPUID();
//					String name=aRequest.getName();
//					String token=aRequest.getToken();
////					String url = "http://websvr.niu.xunlei.com/checkAppUser.gameUserInfo?gameid="+gameID+"&customerid="+params[0].getCustomerId()+"&customerKey="+params[0].getCustomerKey();
//					String[] tokens = token.split(",");
//					
//					String url = "http://websvr.niu.xunlei.com/checkAppUser.gameUserInfo?"+"gameid="+tokens[2]+"&customerid="+tokens[0]+"&customerKey="+tokens[1];
//					System.out.println(url);
//					String msg = Util.doGet(url);
//					System.out.println(msg);
//					JSONObject jsonObject = JSONObject.fromObject(msg);
//					int code = jsonObject.getInt("code");
//					System.out.println(code);
//					if(code == 0){
//						XQClientAccount_Login al2 = (XQClientAccount_Login) aRequest;
//						aPlayer.setPID(al2.getPID());
//						aPlayer.setPUID(al2.getPUID());
//						aPlayer.setToken(token);
//						aPlayer.setName(al2.getName());
//
//						XQServerAccountLoginMsg sal2 = al2
//								.ToXQServerAccountLoginMsg();
//						// 支持多个gate服务，设置sessionId
//						sal2.setGateSession(aPlayer.getGateSessionID());
//						aPlayer.PlayerSendMessgeToServer(sal2, sal2.getType());
//					}
//			} catch (Exception e) {
//				e.printStackTrace();
//			}
//		}
//	}
}
