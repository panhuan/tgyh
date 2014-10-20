package XuanQu.PPHelp;

import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;

import net.sf.json.JSONObject;
import net.sf.json.util.JSONTokener;

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

public class HttpPPHelpHandler extends IoHandlerAdapter {

	private static final Logger logger = LoggerFactory.getLogger("charge");

	@Override
	public void sessionOpened(IoSession session) {
		// set idle time to 60 seconds
		session.getConfig().setIdleTime(IdleStatus.BOTH_IDLE, 60);
	}

	// 收到的消息处理
	@Override
	public void messageReceived(IoSession session, Object message) {
		HttpRequestMessage msg = (HttpRequestMessage) message;

		// 位支付密钥,pp助手分配
		String orderid = null;
		String billno = null;
		String account = null;
		String amount = null;
		String status = null;
		String app_id = null;
		String roleid = null;
		String zone = null;
		String sign = null;

//		logger.debug("order_id==" + msg.getParameter("order_id"));
//		logger.debug("billno==" + msg.getParameter("billno"));
//		logger.debug("account==" + msg.getParameter("account"));
//		logger.debug("amount==" + msg.getParameter("amount"));
//		logger.debug("status==" + msg.getParameter("status"));
//		logger.debug("app_id==" + msg.getParameter("app_id"));
//		logger.debug("roleid==" + msg.getParameter("roleid"));
//		logger.debug("zone==" + msg.getParameter("zone"));
//		logger.debug("sign==" + msg.getParameter("sign"));

		try {
			orderid = URLDecoder.decode(msg.getParameter("order_id"), "UTF-8");
			billno = URLDecoder.decode(msg.getParameter("billno"), "UTF-8");
			account = URLDecoder.decode(msg.getParameter("account"), "UTF-8");
			amount = URLDecoder.decode(msg.getParameter("amount"), "UTF-8");
			status = URLDecoder.decode(msg.getParameter("status"), "UTF-8");
			app_id = URLDecoder.decode(msg.getParameter("app_id"), "UTF-8");
			roleid = URLDecoder.decode(msg.getParameter("roleid"), "UTF-8");
			zone = URLDecoder.decode(msg.getParameter("zone"), "UTF-8");

			sign = URLDecoder.decode(msg.getParameter("sign"), "UTF-8");
		} catch (UnsupportedEncodingException e1) {
			e1.printStackTrace();
		}

//		logger.debug("-----order_id==" + orderid);
//		logger.debug("-----account==" + account);
//		logger.debug("-----amount==" + amount);
//		logger.debug("-----status==" + status);
//		logger.debug("-----app_id==" + app_id);
//		logger.debug("-----roleid==" + roleid);
//		logger.debug("-----zone==" + zone);
//		logger.debug("-----sign==" + sign);
//		logger.debug("-----billno==" + billno);

		String str = orderid + billno + account + amount + status + app_id
				+ roleid + zone;
		String sig;
		try {
			sig = RSAEncrypt.RASDecryotion(sign);

//			logger.debug("-----sig==" + sig);
			String result_sig = ParseJson(sig);

//			logger.debug("-----str==" + str);
//			logger.debug("-----result_sig==" + result_sig);
			HttpResponseMessage response = new HttpResponseMessage();
			response.setResponseCode(HttpResponseMessage.HTTP_STATUS_SUCCESS);

			String _result = "";

			String paymentString[] = roleid.split("_");

			String nAccount = paymentString[0];
			String serverid = paymentString[1];

//			logger.debug("-----nAccount==" + nAccount);
//			logger.debug("-----serverid==" + serverid);
			if (result_sig.equals(str)) {

				Double dAmount = new Double(amount).doubleValue();

				String logMsg = "pid=" + SdkBillingServer.PID_PPHELP;
				logMsg += "&orderid=" + orderid;
				logMsg += "&payway=0";
				logMsg += "&amount=" + (int) (dAmount * 100);
				logMsg += "&account=" + nAccount;
				logMsg += "&serverid=" + serverid;
				logMsg += "&recodedate=" + MyDateFormart.getFormatDate();

				if (status.equals("0")) {

					_result = HttpSendPartBillServer.sendBillServerByServerId(
							nAccount, (int) (dAmount * 100), orderid, "0",
							SdkBillingServer.PID_PPHELP, "", serverid);
//					logger.debug("-----_result==" + _result);
					// 成功
					logMsg += "&cperror=200";
					logger.debug("<errcode=1&errmsg=&" + logMsg + ">");
				} else {
					Double dAmount1 = new Double(amount).doubleValue();

					String logMsg1 = "pid=" + SdkBillingServer.PID_PPHELP;
					logMsg += "&orderid=" + orderid;
					logMsg += "&payway=0";
					logMsg += "&amount=" + (int) (dAmount1 * 100);
					logMsg += "&account=" + nAccount;
					logMsg += "&serverid=" + serverid;
					logMsg += "&recodedate=" + MyDateFormart.getFormatDate();
					// 失败
					logMsg += "&cperror=404";
					logger.debug("<errcode=0&errmsg=Sign无效&" + logMsg1 + ">");
				}

				if (response != null
						&& (_result != null || !"".equals(_result))) {

					response.appendBody("success");
					session.write(response).addListener(IoFutureListener.CLOSE);
				}

			} else {
				response.appendBody("fail");
				if (response != null) {
					session.write(response).addListener(IoFutureListener.CLOSE);
				}

				Double dAmount = new Double(amount).doubleValue();

				String logMsg = "pid=" + SdkBillingServer.PID_PPHELP;
				logMsg += "&orderid=" + orderid;
				logMsg += "&payway=0";
				logMsg += "&amount=" + (int) (dAmount * 100);
				logMsg += "&account=" + nAccount;
				logMsg += "&serverid=" + serverid;
				logMsg += "&recodedate=" + MyDateFormart.getFormatDate();
				// Sign无效
				logMsg += "&cperror=404";
				logger.debug("<errcode=-1&errmsg=Sign无效&" + logMsg + ">");
			}
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
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

	public String ParseJson(String jsonstring) {

		JSONTokener jsonParser = new JSONTokener(jsonstring);
		JSONObject receipt_resultJson = (JSONObject) jsonParser.nextValue();
		String returnString = receipt_resultJson.getString("order_id")
				+ receipt_resultJson.getString("billno")
				+ receipt_resultJson.getString("account")
				+ receipt_resultJson.getString("amount")
				+ receipt_resultJson.getString("status")
				+ receipt_resultJson.getString("app_id")
				+ receipt_resultJson.getString("roleid")
				+ receipt_resultJson.getString("zone");
		return returnString;
	}
}
