package XuanQu.oppo;

import javax.security.auth.login.AccountException;

import com.nearme.oauth.model.AccessToken;
import com.nearme.oauth.open.AccountAgent;



/**
 * @author lijingyin
 * 
 */
public class OPPO {
	
	private String appSecret;

	private String appKey;
	
	public void Init() throws Exception {
		
		appKey=Util.getConfig("AppKey");
		appSecret=Util.getConfig("AppSecret");
		
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
//			
//			try{
//					int pid=aRequest.getPID();
//					String puid=aRequest.getPUID();
//					String name=aRequest.getName();
//					String token=aRequest.getToken();
//					String[] toks=token.split("&");
//					String[] tokeys=toks[0].split("=");
//					String[] toksets=toks[1].split("=");
////					String appKey=Util.getConfig("AppKey");
////					String appSecret=Util.getConfig("AppSecret");
//					String gcUserInfo=AccountAgent.getInstance().getGCUserInfo(new AccessToken(tokeys[1],toksets[1]));
////					System.out.println(gcUserInfo);
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
//			} catch (Exception e) {
//				e.printStackTrace();
//			}
//		}
//	}
}
