package XuanQu.kuaiyong;

import java.net.URLDecoder;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import net.sf.json.JSONObject;
import net.sf.json.util.JSONTokener;

import org.apache.mina.core.future.IoFutureListener;
import org.apache.mina.core.service.IoHandlerAdapter;
import org.apache.mina.core.session.IdleStatus;
import org.apache.mina.core.session.IoSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import sun.misc.BASE64Decoder;

import XuanQu.RWGate.SdkBillingServer;
import XuanQu.httpserver.HttpRequestMessage;
import XuanQu.httpserver.HttpResponseMessage;
import XuanQu.multipleServer.HttpSendPartBillServer;
import XuanQu.util.MyDateFormart;

/**
 * @author banshuai
 * 
 */
public class HttpKuaiYongHandler extends IoHandlerAdapter {
	private static final Logger logger = LoggerFactory.getLogger("charge");

	private final String pubKey = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC76K4sGVkVGVQCfUxWYJkUb4bONl7IWFqUS7m85LIF9mCoBC4CFJqrp9/mm6aS7TFDwshhqSxF2MqRStNLRMKVVDelawBbZBnWaH3vvs9WlPLa5Kqf6qBgwSxfrGVL1EMvG/GH+zHrvu8OaRDL9geTo8K0ivw0C/6JorviJDztxQIDAQAB";

	private String notify_data = "";
	private String orderid = "";
	private String dealseq = "";
	private String sign = "";
	private String uid;
	private String subject;
	private String v;

	@Override
	public void sessionOpened(IoSession session) {
		// set idle time to 60 seconds
		session.getConfig().setIdleTime(IdleStatus.BOTH_IDLE, 60);
	}

	// 收到的消息处理
	@Override
	public void messageReceived(IoSession session, Object message) {
		// 支付接口预留91
		HttpRequestMessage request = (HttpRequestMessage) message;

		HttpResponseMessage response = new HttpResponseMessage();
		response.setResponseCode(HttpResponseMessage.HTTP_STATUS_SUCCESS);

		// 支付通告rsa公钥
		// 签名密钥 Rg5Vx3IwLc7V84Tvo92bc2jZUPj4aEm2

		String resultMessage = "";
		String _result = "";
		try {

			byte[] plainData = getData(request);
			String str_plainData = new String(plainData, "UTF-8");
			String _plainData[] = str_plainData.split("&");
			String payresult = "";
			String sign_dealseq = "";
			String fee = "";

			for (int i = 0, j = _plainData.length; i < j; i++) {
				if (_plainData[i].contains("payresult")) {
					payresult = _plainData[i].split("=")[1];
				} else if (_plainData[i].contains("dealseq")) {
					sign_dealseq = _plainData[i].split("=")[1];
				} else if (_plainData[i].contains("fee")) {
					fee = _plainData[i].split("=")[1];
				}
			}
			
			String paymentString[] = sign_dealseq.split("_");
			String nAccount = paymentString[0];
			String serverid = paymentString[1];

			String logMsg = "pid=" + SdkBillingServer.PID_KUAIYONG;
			logMsg += "&orderid=" + sign_dealseq;
			logMsg += "&payway=" + 0;
			logMsg += "&amount=" + (int) (Double.parseDouble(fee) * 100);
			logMsg += "&account=" + nAccount;
			logMsg += "&serverid=" + serverid;
			logMsg += "&recodedate=" + MyDateFormart.getFormatDate();

			if (payresult.equals("0")) {

				_result = HttpSendPartBillServer.sendBillServerByServerId(
						nAccount, (int) (Double.parseDouble(fee) * 100),
						sign_dealseq, "0", SdkBillingServer.PID_KUAIYONG, "",
						serverid);

				System.currentTimeMillis();

				logMsg += "&cperror=200";
				logger.debug("<errcode=1&errmsg=接收成功&" + logMsg + ">");

				if ((_result != null || !"".equals(_result))
						&& (_result.equals("success"))) {
					resultMessage = "success";
				}
			} else {
				logMsg += "&cperror=404";
				logger.debug("<errcode=0&errmsg=0&" + logMsg + ">");
				resultMessage = "failed";
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			response.appendBody(resultMessage);
			if (response != null) {
				session.write(response).addListener(IoFutureListener.CLOSE);
			}
		}
	}

	private byte[] getData(HttpRequestMessage request) {

		byte[] plainData = null;
		try {
			// request..setCharacterEncoding("UTF-8");
			Map<String, String> transformedMap = new HashMap<String, String>();
			// 获得通知签名
			notify_data = request.getParameter("notify_data");
			String _notify_data=URLDecoder.decode(notify_data);
			transformedMap.put("notify_data", _notify_data);
			orderid = request.getParameter("orderid");
			transformedMap.put("orderid", orderid);
			sign = request.getParameter("sign");
			String _sign=URLDecoder.decode(sign);
			transformedMap.put("sign", _sign);
			dealseq = request.getParameter("dealseq");
			transformedMap.put("dealseq", dealseq);
			uid = request.getParameter("uid");
			transformedMap.put("uid", uid);
			subject = request.getParameter("subject");
			String _subject=URLDecoder.decode(subject);
			transformedMap.put("subject", _subject);
			v = request.getParameter("v");
			transformedMap.put("v", v);

			// rsa签名验签
			String verify = getVerifyData(transformedMap);
//			logger.info("verfiy data:" + verify);
//			logger.info("sign is:" + sign);
			if (!RSASignature.doCheck(verify, _sign, pubKey, "utf-8")) {
				logger.info("RSA验签失败，数据不可信" + verify);
			} else {
//				logger.info("RSA验签成功，数据可信:" + verify);
				RSAEncrypt rsaEncrypt = new RSAEncrypt();
				BASE64Decoder base64Decoder = new BASE64Decoder();

				// 加载公钥
				try {
					rsaEncrypt.loadPublicKey(pubKey);
//					logger.info("加载公钥成功");
				} catch (Exception e) {
					logger.error("load rsa public key failed, 加载公钥失败");
				}

				// 公钥解密通告加密数据
				notify_data=URLDecoder.decode(notify_data, "utf-8");
				byte[] dcDataStr = base64Decoder.decodeBuffer(notify_data);
				plainData = rsaEncrypt.decrypt(rsaEncrypt.getPublicKey(),
						dcDataStr);
//				logger.info("KuaiYong Notify Data:"
//						+ new String(plainData, "UTF-8"));
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		return plainData;
	}

	/**
	 * 获得验签名的数据
	 * 
	 * @param map
	 * @return
	 */
	private String getVerifyData(Map<String, String> map) {
		String signData = getSignData(map);
		return signData;
	}

	/**
	 * 获得MAP中的参数串；
	 * 
	 * @param params
	 * @return
	 */
	public static String getSignData(Map<String, String> params) {
		StringBuffer content = new StringBuffer();
		List<String> keys = new ArrayList<String>(params.keySet());
		Collections.sort(keys);

		for (int i = 0; i < keys.size(); i++) {
			String key = (String) keys.get(i);

			if ("sign".equals(key)) {
				continue;
			}
			String value = (String) params.get(key);
			if (value != null) {
				content.append((i == 0 ? "" : "&") + key + "=" + value);
			} else {
				content.append((i == 0 ? "" : "&") + key + "=");
			}
		}
		return content.toString();
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
