package XuanQu.baidu;

import java.net.URLEncoder;

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

public class HttpBaiDuHandler extends IoHandlerAdapter {
	private static final Logger logger = LoggerFactory.getLogger("charge");

	@Override
	public void sessionOpened(IoSession session) {
		// set idle time to 60 seconds
		session.getConfig().setIdleTime(IdleStatus.BOTH_IDLE, 60);
	}

	@Override
	public void messageReceived(IoSession session, Object message) {

		HttpRequestMessage msg = (HttpRequestMessage) message;

		// 12位支付密钥,当乐分配
		String AppSecret = "";

		try {
			AppSecret = Util.getConfig("AppSecret");
		} catch (Exception e) {
			e.printStackTrace();
		}

		String amount = msg.getParameter("amount");
		String cardtype = msg.getParameter("cardtype");
		String orderid = msg.getParameter("orderid");
		String result = msg.getParameter("result");
		String timetamp = msg.getParameter("timetamp");
		String aid = msg.getParameter("aid");
		String client_secret = msg.getParameter("client_secret");

		String _aid = URLEncoder.encode(aid);

		String str = amount + cardtype + orderid + result + timetamp
				+ AppSecret + _aid;
		String sig = Util.getMD5(str).toLowerCase();

		HttpResponseMessage response = new HttpResponseMessage();
		response.setResponseCode(HttpResponseMessage.HTTP_STATUS_SUCCESS);

		String _result = "";
		
		if (client_secret != null && sig.equals(client_secret)) {
			String paymentString[] = _aid.split("_");

			String nAccount = paymentString[0];
			String serverid = paymentString[1];

			Double dAmount = new Double(amount).doubleValue();

			String logMsg = "pid=" + SdkBillingServer.PID_BAIDU;
			logMsg += "&orderid=" + orderid;
			logMsg += "&payway=" + cardtype;
			logMsg += "&amount=" + (int) (dAmount * 100);
			logMsg += "&account=" + nAccount;
			logMsg += "&serverid=" + serverid;
			logMsg += "&recodedate=" + MyDateFormart.getFormatDate();
			
			if ("1".equals(result)) {
				_result = HttpSendPartBillServer
						.sendBillServerByServerId(nAccount, (int)(dAmount * 100), orderid,
								cardtype, SdkBillingServer.PID_BAIDU, "", serverid);
				// 成功
				logMsg += "&cperror=200";
				logger.debug("<errcode=1&errmsg=&" + logMsg + ">");
			} else if ("2".equals(result)) {
				// 失败
				logMsg += "&cperror=404";
				logger.debug("<errcode=0&errmsg=&" + logMsg + ">");
			}
			
			if (response != null && (_result != null || !"".equals(_result))) {
				response.appendBody("SUCCESS");
				session.write(response).addListener(IoFutureListener.CLOSE);
			}
//			System.out.println("_result=" + _result);
		} else {
			response.appendBody("ERROR_SIGN");
			if (response != null) {
				session.write(response).addListener(IoFutureListener.CLOSE);
			}

			int nAccount = Integer.parseInt(aid);
			Double dAmount = new Double(amount).doubleValue();

			String logMsg = "pid=" + SdkBillingServer.PID_BAIDU;
			logMsg += "&orderid=" + orderid;
			logMsg += "&payway=0";
			logMsg += "&amount=" + (int) (dAmount * 100);
			logMsg += "&account=" + nAccount;
			logMsg += "&serverid=";
			logMsg += "&recodedate=" + MyDateFormart.getFormatDate();
			// Sign无效
			logMsg += "&cperror=404";
			logger.debug("<errcode=-1&errmsg=Sign无效&" + logMsg + ">");
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
