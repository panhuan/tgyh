package XuanQu.gamecenter;


/**
 * @author chenhui
 *
 */

public class GameCenter {
	
	public void Init() throws Exception {
		
	}
	
//	public void checkSessionId(Player aPlayer, XQClientAccount_Login aRequest) {
//		
//		if (aRequest != null && aPlayer != null) {
//			try {
//
//				XQClientAccount_Login al2 = (XQClientAccount_Login) aRequest;
//
//				aPlayer.setPID(al2.getPID());
//				aPlayer.setPUID(al2.getPUID());
//				aPlayer.setToken(al2.getToken());
//				aPlayer.setName(al2.getName());
//				aPlayer.setM_nVID(al2.getM_nVID());
//
//				XQServerAccountLoginMsg sal2 = al2.ToXQServerAccountLoginMsg();
//				// 支持多个gate服务，设置sessionId
//				sal2.setGateSession(aPlayer.getGateSessionID());
//				aPlayer.PlayerSendMessgeToServer(sal2, sal2.getType());
//
//			} catch (Exception e) {
//				e.printStackTrace();
//			}
//
//		}
//	}

}