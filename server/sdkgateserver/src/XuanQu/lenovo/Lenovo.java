package XuanQu.lenovo;

import java.text.SimpleDateFormat;
import java.util.Date;





import net.sf.json.JSONObject;

import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.HttpStatus;
import org.apache.commons.httpclient.NameValuePair;
import org.apache.commons.httpclient.methods.PostMethod;


/**
 * @author lijingyin
 * 
 */
public class Lenovo {

	private String checkUrl;
	private String realm;
//	private String queryUrl;

	public void Init() throws Exception {

		realm = Util.getConfig("realm");
		checkUrl = Util.getConfig("checkUrl");
	}

	// public String getPaymentKey(){
	// return paymentKey;
	// }

	/**
	 * 检查用户登陆sessionId是否有效
	 * 
	 * @param aPlayer
	 * @param aRequest
	 */

//	public void checkSessionId(Player aPlayer, XQClientAccount_Login aRequest) {
//		if (aRequest != null && aPlayer != null) {
//
//		
//			
//			String token =aRequest.getToken();
//			
//			String url=checkUrl+"lpsust="+token+"&realm="+realm;
//			String reqMsg=Util.doGet(url);
//			int acd1=reqMsg.indexOf("AccountID")+10;
//			int acd2=reqMsg.lastIndexOf("AccountID")-2;
//			String accountId=reqMsg.substring(acd1, acd2);
//			
//			short pid = aRequest.getPID();
//			String puid = accountId;
//			String name = aRequest.getName();
//			
//				XQClientAccount_Login al2 = (XQClientAccount_Login) aRequest;
//				aPlayer.setPID(pid);
//				aPlayer.setPUID(puid);
//				aPlayer.setToken(token);
//				aPlayer.setName(al2.getName());
//				XQServerAccountLoginMsg sal2 = al2.ToXQServerAccountLoginMsg();
//				// 支持多个gate服务，设置sessionId
//				sal2.setPUID(puid);
//				sal2.setGateSession(aPlayer.getGateSessionID());
//				aPlayer.PlayerSendMessgeToServer(sal2, sal2.getType());
//			
//		}
//	}
}
