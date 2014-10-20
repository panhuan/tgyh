package XuanQu.i4399;

import java.net.URLDecoder;

import org.apache.mina.core.future.IoFutureListener;
import org.apache.mina.core.service.IoHandlerAdapter;
import org.apache.mina.core.session.IdleStatus;
import org.apache.mina.core.session.IoSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import XuanQu.RWGate.SdkBillingServer;
import XuanQu.baidu.Util;
import XuanQu.httpserver.HttpRequestMessage;
import XuanQu.httpserver.HttpResponseMessage;
import XuanQu.multipleServer.HttpSendPartBillServer;
import XuanQu.util.MyDateFormart;

public class HttpI4399Handler extends IoHandlerAdapter {
	private static final Logger logger = LoggerFactory.getLogger("charge");

	@Override
	public void sessionOpened(IoSession session) {
		// set idle time to 60 seconds
		session.getConfig().setIdleTime(IdleStatus.BOTH_IDLE, 60);
	}

	@Override
	public void messageReceived(IoSession session, Object message) {

		HttpRequestMessage msg = (HttpRequestMessage) message;

		// 位支付密钥,4399分配
		String key = "b9066aa0fc26ef8fe6309b244fc9ff7d";

		String orderid = msg.getParameter("orderid");
		String appkey = msg.getParameter("appkey");
		String uid = msg.getParameter("uid");
		String username = msg.getParameter("username");
		
		username = URLDecoder.decode(username);
		
		String money = msg.getParameter("money");
		String gamemoney = msg.getParameter("gamemoney");
		String server = msg.getParameter("server");
		String mark = msg.getParameter("mark");
		String sign = msg.getParameter("sign");

		String str = orderid + appkey + uid + username + money + gamemoney
				+ server + mark + key;
		String sig = Util.getMD5(str);

		HttpResponseMessage response = new HttpResponseMessage();
		response.setResponseCode(HttpResponseMessage.HTTP_STATUS_SUCCESS);

		String _result = "";

		String nAccount = mark;
		String serverid = server;

		if (sig.equals(sign)) {
//			String paymentString[] = mark.split("_");
			
			Double dAmount = new Double(money).doubleValue();

			String logMsg = "pid=" + SdkBillingServer.PID_4399;
			logMsg += "&orderid=" + orderid;
			logMsg += "&payway=0";
			logMsg += "&amount=" + (int) (dAmount * 100);
			logMsg += "&account=" + nAccount;
			logMsg += "&serverid=" + serverid;
			logMsg += "&recodedate=" + MyDateFormart.getFormatDate();

			_result = HttpSendPartBillServer
					.sendBillServerByServerId(nAccount, (int)(dAmount * 100), orderid,
							"0", SdkBillingServer.PID_4399, "", serverid);
			
			if (response != null && (_result != null || !"".equals(_result))) {
				response.appendBody("1");
				session.write(response).addListener(IoFutureListener.CLOSE);
			} else {
				response.appendBody("-2");
				session.write(response).addListener(IoFutureListener.CLOSE);
			}
			// 成功
			logMsg += "&cperror=200";
			logger.debug("<errcode=1&errmsg=&" + logMsg + ">");
		} else {
			response.appendBody("-2");
			if (response != null) {
				session.write(response).addListener(IoFutureListener.CLOSE);
			}

			Double dAmount = new Double(money).doubleValue();

			String logMsg = "pid=" + SdkBillingServer.PID_4399;
			logMsg += "&orderid=" + orderid;
			logMsg += "&payway=0";
			logMsg += "&amount=" + (int) (dAmount * 100);
			logMsg += "&account=" + nAccount;
			logMsg += "&serverid=" + serverid;
			logMsg += "&recodedate=" + MyDateFormart.getFormatDate();
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
