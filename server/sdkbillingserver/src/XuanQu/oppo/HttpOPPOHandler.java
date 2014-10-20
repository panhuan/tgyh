package XuanQu.oppo;

import java.net.URLDecoder;
import java.security.KeyFactory;
import java.security.PublicKey;
import java.security.spec.X509EncodedKeySpec;
import java.util.HashMap;
import java.util.Map;

import org.apache.mina.core.future.IoFutureListener;
import org.apache.mina.core.service.IoHandlerAdapter;
import org.apache.mina.core.session.IdleStatus;
import org.apache.mina.core.session.IoSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.apache.commons.codec.binary.Base64;

import XuanQu.RWGate.SdkBillingServer;
import XuanQu.httpserver.HttpRequestMessage;
import XuanQu.httpserver.HttpResponseMessage;
import XuanQu.multipleServer.HttpSendPartBillServer;
import XuanQu.util.MyDateFormart;

/**
 * @author banshuai
 * 
 */
public class HttpOPPOHandler extends IoHandlerAdapter {
	private static final Logger logger = LoggerFactory.getLogger("charge");
	
	private static final String PUB_KEY = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCmreYIkPwVovKR8rLHWlFVw7YDfm9uQOJKL89Smt6ypXGVdrAKKl0wNYc3/jecAoPi2ylChfa2iRu5gunJyNmpWZzlCNRIau55fxGW0XEu553IiprOZcaw5OuYGlf60ga8QT6qToP0/dpiL/ZbmNUO9kUhosIjEu22uFgR+5cYyQIDAQAB";
	@Override
	public void sessionOpened(IoSession session) {
		// set idle time to 60 seconds
		session.getConfig().setIdleTime(IdleStatus.BOTH_IDLE, 60);
	}

	// 收到的消息处理
	@Override
	public void messageReceived(IoSession session, Object message) {
		// 支付接口预留
		
		HttpRequestMessage request = (HttpRequestMessage) message;

		HttpResponseMessage response = new HttpResponseMessage();
		response.setResponseCode(HttpResponseMessage.HTTP_STATUS_SUCCESS);
		String _payAmount = request.getParameter("price");
		String _mpaymentString = request.getParameter("attach");
		String productDesc = request.getParameter("productDesc");
		String _orderId = request.getParameter("partnerOrder");
		String _signMsg = request.getParameter("sign");
		String count = request.getParameter("count");
		String attach = request.getParameter("attach");
		String notifyId = request.getParameter("notifyId");
		String productName = request.getParameter("productName");
		String msg="sign="+_signMsg+
				"&partnerOrder="+_orderId+
				"&productDesc="+productDesc+
				"&price="+_payAmount+
				"&count="+count+
				"&attach="+attach+
				"&notifyId="+notifyId+
				"&productName="+productName;
		String content=getKebiContentString(msg);
	
		String payAmount;
		String mpaymentString;
		String orderId;
		String signMsg;
		
		payAmount=URLDecoder.decode(_payAmount);
		mpaymentString=URLDecoder.decode(_mpaymentString);
		orderId=URLDecoder.decode(_orderId);
		signMsg=URLDecoder.decode(_signMsg);
		String paymentString[] = mpaymentString.split("_");
		String nAccount = paymentString[0];
		String serverid = paymentString[1];
		double dAmount=Double.parseDouble(payAmount);
		String _result = "";
		
		boolean result=doCheck(URLDecoder.decode(content), signMsg);
		
		
			String logMsg = "pid=" + SdkBillingServer.PID_OPPO;
			logMsg += "&orderid=" + orderId;
			logMsg += "&payway=" + "0";
			logMsg += "&amount=" + (int) (dAmount * 1);
			logMsg += "&account=" + nAccount;
			logMsg += "&serverid=" + serverid;
			logMsg += "&recodedate=" + MyDateFormart.getFormatDate();
			
			if(result){

				_result = HttpSendPartBillServer
							.sendBillServerByServerId(nAccount, (int) (dAmount * 1), orderId,
									"0", SdkBillingServer.PID_OPPO, "", serverid);
				
				if (response != null && "success".equals(_result)) {
					response.appendBody("result=OK&resultMsg=成功");
					session.write(response).addListener(IoFutureListener.CLOSE);
				} else {
					response.appendBody("result=FAIL&resultMsg=服务器网络连接失败");
					session.write(response).addListener(IoFutureListener.CLOSE);
				}
				// 成功

				logMsg += "&cperror=200";
				logger.debug("<errcode=1&errmsg=&" + logMsg + ">");
			}else{
				response.appendBody("result=FAIL&resultMsg=签名验证失败");
				if (response != null) {
					session.write(response).addListener(IoFutureListener.CLOSE);
				}
				// Sign无效
				logMsg += "&cperror=404";
				logger.debug("<errcode=0&errmsg=Sign无效&" + logMsg + ">");
			}
	}
	

	private static String getKebiContentString(String url) {
		final String[] strings = url.split("&");
		final Map<String, String> data = new HashMap<String, String>();
		for (String string : strings) {
			final String[] keyAndValue = string.split("=");
			data.put(keyAndValue[0], keyAndValue[1]);
		}
		final StringBuilder baseString = new StringBuilder();
		baseString.append("notifyId=");
		baseString.append(data.get("notifyId"));
		baseString.append("&");
		baseString.append("partnerOrder=");
		baseString.append(data.get("partnerOrder"));
		baseString.append("&");
		baseString.append("productName=");
		baseString.append(data.get("productName"));
		baseString.append("&");
		baseString.append("productDesc=");
		baseString.append(data.get("productDesc"));
		baseString.append("&");
		baseString.append("price=");
		baseString.append(data.get("price"));
		baseString.append("&");
		baseString.append("count=");
		baseString.append(data.get("count"));
		baseString.append("&");
		baseString.append("attach=");
		baseString.append(data.get("attach"));
		return baseString.toString();
	}
	
	public static boolean doCheck(String content, String sign) {
		String charset = "utf-8";
		try {
			KeyFactory keyFactory = KeyFactory.getInstance("RSA");
			byte[] encodedKey = Base64.decodeBase64(PUB_KEY.getBytes());
			PublicKey pubKey = keyFactory
					.generatePublic(new X509EncodedKeySpec(encodedKey));
			java.security.Signature signature = java.security.Signature
					.getInstance("SHA1WithRSA");
			signature.initVerify(pubKey);
			signature.update(content.getBytes(charset));
			boolean bverify = signature.verify(Base64.decodeBase64(sign
					.getBytes()));
			return bverify;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return false;
	}
	
	private static String getSign(String url) {
		final String[] strings = url.split("&");
		final StringBuilder sb = new StringBuilder();
		for (String string : strings) {
			if (string.startsWith("sign=")) {
				sb.append(string.split("=")[1]);
			}
		}
		return sb.toString();
	}
	
	@Override
	public void sessionIdle(IoSession session, IdleStatus status) {
		// IoSessionLogger.getLogger(session).info("Disconnecting the idle.");
		session.close(true);
	}

	@Override
	public void exceptionCaught(IoSession session, Throwable cause) {
		// IoSessionLogger.getLogger(session).warn(cause);
		session.close(true);
	}
}
