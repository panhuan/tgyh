package XuanQu.anzhi;

import java.io.IOException;
import java.net.URLDecoder;
import java.text.SimpleDateFormat;
import java.util.Date;

import net.sf.json.JSONObject;

import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.HttpStatus;
import org.apache.commons.httpclient.NameValuePair;
import org.apache.commons.httpclient.methods.PostMethod;
import org.apache.mina.core.future.IoFutureListener;
import org.apache.mina.core.service.IoHandlerAdapter;
import org.apache.mina.core.session.IdleStatus;
import org.apache.mina.core.session.IoSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import XuanQu.RWGate.SdkBillingServer;
import XuanQu.httpserver.HttpRequestMessage;
import XuanQu.httpserver.HttpResponseMessage;
import XuanQu.multipleServer.HttpSendPartBillServer;
import XuanQu.util.MyDateFormart;

public class HttpAnZhiHandler extends IoHandlerAdapter {
	private static final Logger logger = LoggerFactory.getLogger("charge");

	@Override
	public void sessionOpened(IoSession session) {
		// set idle time to 60 seconds
		session.getConfig().setIdleTime(IdleStatus.BOTH_IDLE, 60);
	}

	@Override
	public void messageReceived(IoSession session, Object message) {

		HttpRequestMessage msg = (HttpRequestMessage) message;

		String _data = msg.getParameter("data");
		String appSecret = "";
		String orderUrl = "";
		try {
			appSecret = Util.getConfig("APPSECRET");
			orderUrl = Util.getConfig("orderUrl");
		} catch (Exception e) {
			e.printStackTrace();
		}
		String data = Des3Util.decrypt(URLDecoder.decode(_data), appSecret);
		JSONObject json = JSONObject.fromObject(data);
		String uid = json.getString("uid");
		String orderAmount = json.getString("orderAmount");
		String orderId = json.getString("orderId");
		String code = json.getString("code");
		String msg1 = json.getString("msg");
		String payAmount = json.getString("payAmount");
		String cpInfo = json.getString("cpInfo");
		String memo = json.getString("memo");
		String orderTime = json.getString("orderTime");

		String paymentStr[] = cpInfo.split("&@&");
		String _orderId = paymentStr[1];
		String servers[] = paymentStr[0].split("_");
		String nAccount = servers[0];
		String serverid = servers[1];

		HttpClient httpclient = new HttpClient();
		PostMethod post = new PostMethod(orderUrl);
		String respStr = null;
		String appKey = "";
		try {
			appKey = Util.getConfig("APPKEY");
		} catch (Exception e) {
			e.printStackTrace();
		}
		String mintradetime = "";
		String maxtradetime = "";
		SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmssSSS");
		String time = sdf.format(new Date());
		String sign = Base64.encodeToString(appKey + orderId + mintradetime
				+ maxtradetime + appSecret);
		post.setRequestHeader("Content-type", "text/xml; charset=UTF-8");
		NameValuePair[] queryData = { new NameValuePair("appkey", appKey),
				new NameValuePair("tradenum", orderId),
				new NameValuePair("mintradetime", mintradetime),
				new NameValuePair("maxtradetime", maxtradetime),
				new NameValuePair("sign", sign),
				new NameValuePair("time", time) };
		post.setQueryString(queryData);
		httpclient.getHostConfiguration().setHost(orderUrl);
		int result = 0;
		try {
			result = httpclient.executeMethod(post);
		} catch (Exception e1) {
			e1.printStackTrace();
		}
		if (result == HttpStatus.SC_OK) {
			try {
				respStr = post.getResponseBodyAsString();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		JSONObject resJson = JSONObject.fromObject(respStr);
		String sc = resJson.getString("sc");

		String money = payAmount;
		if (money.equals("0")) {
			money = orderAmount;
		}
		HttpResponseMessage response = new HttpResponseMessage();
		response.setResponseCode(HttpResponseMessage.HTTP_STATUS_SUCCESS);

		String logMsg = "pid=" + SdkBillingServer.PID_ANZHI;
		logMsg += "&orderid=" + _orderId;
		logMsg += "&payway=" + "0";
		logMsg += "&amount=" + orderAmount;
		logMsg += "&account=" + money;
		logMsg += "&serverid=" + serverid;
		logMsg += "&recodedate=" + MyDateFormart.getFormatDate();

		if (sc.equals("1")) {
			String _result = "";
			_result = HttpSendPartBillServer.sendBillServerByServerId(nAccount,
					Integer.parseInt(money), _orderId, "0",
					SdkBillingServer.PID_ANZHI, "", serverid);

			if (response != null && "success".equals(_result)) {
				String repost = "success";
				response.appendBody(repost);
				session.write(response).addListener(IoFutureListener.CLOSE);
			} else {
				session.write(response).addListener(IoFutureListener.CLOSE);
			}
			logMsg += "&cperror=200";
			logger.debug("<errcode=1&errmsg=&" + logMsg + ">");
		} else {
			if (response != null) {
				session.write(response).addListener(IoFutureListener.CLOSE);
			}
			// Sign无效
			logMsg += "&cperror=404";
			logger.debug("<errcode=0&errmsg=Sign无效&" + logMsg + ">");
		}

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
