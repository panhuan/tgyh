package XuanQu.downjoy;

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

public class HttpDownjoyHandler extends IoHandlerAdapter {
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
		String paymentKey = "";

		try {
			paymentKey = Util.getConfig("PaymengKey");
		} catch (Exception e) {
			e.printStackTrace();
		}

		String result = msg.getParameter("result");
		String money = msg.getParameter("money");
		String orderNo = msg.getParameter("order");
		String memberId = msg.getParameter("mid");
		String dateTime = msg.getParameter("time");
		String signature = msg.getParameter("signature");
		String ext = msg.getParameter("ext");
		
		String str = "order=" + orderNo + "&money=" + money + "&mid="
				+ memberId + "&time=" + dateTime + "&result=" + result
				+ "&ext=" + ext + "&key=" + paymentKey;
		
		String sig = Util.getMD5(str).toLowerCase();

		String paymentString[] = ext.split("_");

		String nAccount = paymentString[0];
		String serverid = paymentString[1];

		if (signature != null && sig.equals(signature)) {
			// int nAccount = Integer.parseInt(ext);

			Double dAmount = new Double(money).doubleValue();

			String logMsg = "pid=" + SdkBillingServer.PID_DOWNJOY;
			logMsg += "&orderid=" + orderNo;
			logMsg += "&payway=0";
			logMsg += "&amount=" + (int) (dAmount * 100);
			logMsg += "&account=" + nAccount;
			logMsg += "&serverid=" + serverid;
			logMsg += "&recodedate=" + MyDateFormart.getFormatDate();

			HttpResponseMessage response = new HttpResponseMessage();
			response.setResponseCode(HttpResponseMessage.HTTP_STATUS_SUCCESS);
			
			String _result = "";
			
			if ("1".equals(result)) {
				_result = HttpSendPartBillServer
						.sendBillServerByServerId(nAccount, (int)(dAmount * 100), orderNo,
								"0", SdkBillingServer.PID_DOWNJOY, "", serverid);
				
				logMsg += "&cperror=200";
				logger.debug("<errcode=1&errmsg=&" + logMsg + ">");
			} else if ("0".equals(result)) {
				// 失败
				logMsg += "&cperror=404";
				logger.debug("<errcode=0&errmsg=&" + logMsg + ">");
			}

			if (response != null) {
				response.appendBody("success");
				session.write(response).addListener(IoFutureListener.CLOSE);
			}
		} else {
			Double dAmount = new Double(money).doubleValue();

			String logMsg = "pid=" + SdkBillingServer.PID_DOWNJOY;
			logMsg += "&orderid=" + orderNo;
			logMsg += "&payway=0";
			logMsg += "&amount=" + (int) (dAmount * 100);
			logMsg += "&account=" + nAccount;
			logMsg += "&serverid=" + serverid;
			logMsg += "&recodedate=" + MyDateFormart.getFormatDate();
			logMsg += "&cperror=404";
			// Sign无效
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
