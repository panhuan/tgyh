package XuanQu.anzhi;

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
public class AnZhi {

	private String appSecret;
	private String appKey;
	private String queryUrl;

	public void Init() throws Exception {

		appKey = Util.getConfig("AppKey");
		appSecret = Util.getConfig("AppSecret");
		queryUrl = Util.getConfig("QueryRoleUrl");
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
//			try {
//				short pid = aRequest.getPID();
//				String puid = aRequest.getPUID();
//				String name = aRequest.getName();
//				String sid = aRequest.getToken();
//				String time = new SimpleDateFormat("yyyyMMddHHmmssSSS")
//						.format(new Date());
//				String sign = Base64.encodeToString(appKey + name + sid
//						+ appSecret);
//				String url = queryUrl + "?" + "time=" + time + "&appkey="
//						+ appKey + "&account=" + name + "&sid=" + sid
//						+ "&sign=" + sign;
//
//				PostMethod post = new PostMethod(
//						"http://user.anzhi.com/web/api/sdk/third/1/queryislogin");
//				String respStr = null;
//
//				post
//						.setRequestHeader("Content-type",
//								"text/xml; charset=UTF-8");
//				NameValuePair[] data = { new NameValuePair("appkey", appKey),
//						new NameValuePair("account", name),
//						new NameValuePair("sid", sid),
//						new NameValuePair("sign", sign),
//						new NameValuePair("time", time) };
//				post.setQueryString(data);
//				HttpClient httpclient = new HttpClient();
//				httpclient
//						.getHostConfiguration()
//						.setHost(
//								"http://user.anzhi.com/web/api/sdk/third/1/queryislogin");
//				int result = 0;
//				result = httpclient.executeMethod(post);
//				if (result == HttpStatus.SC_OK) {
//					respStr = post.getResponseBodyAsString();
//					
//				}
//				// String appKey=Util.getConfig("AppKey");
//				JSONObject json=JSONObject.fromObject(respStr);
//				String sc=json.getString("sc");
//				if(sc.equals("1")){
//					
//					XQClientAccount_Login al2 = (XQClientAccount_Login) aRequest;
//					aPlayer.setPID(pid);
//					aPlayer.setPUID(puid);
//					aPlayer.setToken(sid);
//					aPlayer.setName(al2.getName());
//					XQServerAccountLoginMsg sal2 = al2.ToXQServerAccountLoginMsg();
//					// 支持多个gate服务，设置sessionId
//					sal2.setGateSession(aPlayer.getGateSessionID());
//					aPlayer.PlayerSendMessgeToServer(sal2, sal2.getType());
//				}
//				
//
//			} catch (Exception e) {
//				e.printStackTrace();
//			}
//		}
//	}
}
