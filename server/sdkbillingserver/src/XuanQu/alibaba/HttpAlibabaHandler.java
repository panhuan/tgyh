package XuanQu.alibaba;

import java.net.URLDecoder;

import org.apache.mina.core.future.IoFutureListener;
import org.apache.mina.core.service.IoHandlerAdapter;
import org.apache.mina.core.session.IdleStatus;
import org.apache.mina.core.session.IoSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import XuanQu.RWGate.SdkBillingServer;
import XuanQu.alibaba.Util;
import XuanQu.httpserver.HttpRequestMessage;
import XuanQu.httpserver.HttpResponseMessage;
import XuanQu.multipleServer.HttpSendPartBillServer;
import XuanQu.util.MyDateFormart;

public class HttpAlibabaHandler extends IoHandlerAdapter {
	private static final Logger logger = LoggerFactory.getLogger("charge");

	@Override
	public void sessionOpened(IoSession session) {
		// set idle time to 60 seconds
		session.getConfig().setIdleTime(IdleStatus.BOTH_IDLE, 60);
	}

	@Override
	public void messageReceived(IoSession session, Object message) {

		HttpRequestMessage msg = (HttpRequestMessage) message;

		// String key = "b9066aa0fc26ef8fe6309b244fc9ff7d";

		String app_order_id = msg.getParameter("app_order_id");
		String coin_order_id = msg.getParameter("coin_order_id");
		String consume_amount = msg.getParameter("consume_amount");
		String credit_amount = msg.getParameter("credit_amount");
		String ts = msg.getParameter("ts");
		String sign = msg.getParameter("sign");
		String is_success = msg.getParameter("is_success");

		String str = "";
		try {
			if (credit_amount == "") {
				str = "app_order_id" + app_order_id + "coin_order_id"
						+ coin_order_id + "consume_amount" + consume_amount
						+ "is_success" + is_success + "ts" + ts
						+ Util.getConfig("AppSecret");
			} else {
				str = "app_order_id" + app_order_id + "coin_order_id"
						+ coin_order_id + "consume_amount" + consume_amount
						+ "credit_amount" + credit_amount + "is_success"
						+ is_success + "ts" + ts + Util.getConfig("AppSecret");
			}

		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		String sig = Util.getMD5(str);

		HttpResponseMessage response = new HttpResponseMessage();
		response.setResponseCode(HttpResponseMessage.HTTP_STATUS_SUCCESS);

		String _result = "";

		String userMsg[] = app_order_id.split("_");
		String nAccount = userMsg[0];
		String serverid = userMsg[1];
		Double dAmount = new Double(consume_amount).doubleValue();

		String logMsg = "pid=" + SdkBillingServer.PID_ALIBABA;
		logMsg += "&orderid=" + app_order_id;
		logMsg += "&payway=0";
		logMsg += "&amount=" + (int) (dAmount * 100);
		logMsg += "&account=" + nAccount;
		logMsg += "&serverid=" + serverid;
		logMsg += "&recodedate=" + MyDateFormart.getFormatDate();
		String responseStr="";
		if (sig.equals(sign)) {
			// String paymentString[] = mark.split("_");

			_result = HttpSendPartBillServer.sendBillServerByServerId(nAccount,
					(int) (dAmount*1), app_order_id, "0",
					SdkBillingServer.PID_ALIBABA, "", serverid);
			 responseStr="{\"is_success\":\"T\",\" app_order_id\":\"" + app_order_id
			+ "\",\"coin_order_id\":\"" + coin_order_id + "\"}";
			response.appendBody(responseStr);
			session.write(response).addListener(IoFutureListener.CLOSE);

			// 成功
			logMsg += "&cperror=200";
			logger.debug("<errcode=1&errmsg=&" + logMsg + ">");
		} else {
			responseStr = "{\"is_success\":\"T\", \"app_order_id\":\"" + app_order_id
					+ "\",\"coin_order_id\":\"" + coin_order_id
					+ "\",\"error_code\":\"FALL\",\"msg\":\"system error\"}";
			response.appendBody(responseStr);
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
