package XuanQu.tongbutui;

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
import XuanQu.util.Util;

/**
 * @author banshuai
 * 
 */
public class HttpTongBuTuiHandler extends IoHandlerAdapter {
	private static final Logger logger = LoggerFactory.getLogger("charge");

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
		
		String key = "qgNDaP@zKWuj7GdTq4NCPm@z*Wt7vGdq";

		String resultMessage = "";
		String _result = "";
		try {
			String source = request.getParameter("source");
			String trade_no = request.getParameter("trade_no");
			String amount = request.getParameter("amount");
			String partner = request.getParameter("partner");
			String paydes = request.getParameter("paydes");
			String debug = request.getParameter("debug");
			String tborder = request.getParameter("tborder");
			String sign = request.getParameter("sign");
			
			String strSign = "source=" + source;
			strSign += "&trade_no=" + trade_no;
			strSign += "&amount=" + amount;
			strSign += "&partner=" + partner;
			strSign += "&paydes=" + paydes;
			strSign += "&debug=" + debug;
			strSign += "&tborder=" + tborder;
			strSign += "&key=" + key;
			

			String iSign = Util.getMD5(strSign).toLowerCase();

			if (iSign.equals(sign) && !"1".equals(debug)) {

				String paymentString[] = paydes.split("_");
				String nAccount = paymentString[0];
				String serverid = paymentString[1];

				String logMsg = "pid=" + SdkBillingServer.PID_TONGBUTUI;
				logMsg += "&orderid=" + trade_no;
				logMsg += "&payway=" + paydes;
				logMsg += "&amount=" + (int) (Double.parseDouble(amount));
				logMsg += "&account=" + nAccount;
				logMsg += "&serverid=" + serverid;
				logMsg += "&recodedate=" + MyDateFormart.getFormatDate();

				_result = HttpSendPartBillServer
						.sendBillServerByServerId(nAccount,
								(int) (Double.parseDouble(amount)),
								trade_no, "0", SdkBillingServer.PID_TONGBUTUI, "",
								serverid);

				logMsg += "&cperror=200";
				logger.debug("<errcode=1&errmsg=接收成功&" + logMsg + ">");

				if ((_result != null || !"".equals(_result))
						&& (_result.equals("success"))) {
					resultMessage = "{\"status\":\"success\"}";
				}
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
