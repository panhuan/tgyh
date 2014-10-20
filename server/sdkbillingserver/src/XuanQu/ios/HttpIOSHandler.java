package XuanQu.ios;

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
import XuanQu.ios.model.ResponseReceived;
import XuanQu.util.MyDateFormart;

/**
 * @author banshuai
 * 
 */
public class HttpIOSHandler extends IoHandlerAdapter {
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

		// String strReturn = IOS.payCallback(msg, logger);
		HttpResponseMessage response = new HttpResponseMessage();
		response.setResponseCode(HttpResponseMessage.HTTP_STATUS_SUCCESS);

		// 内付费正式server地址
		String ServerUrl = "";
		// 内付费测试server地址
		String TestServerUrl = "";

		try {
			ServerUrl = Util.getConfig("ServerUrl");
			TestServerUrl = Util.getConfig("TestServerUrl");
		} catch (Exception e1) {
			e1.printStackTrace();
		}

		String resultMessage = "";
		try {

			String receipt_data = request.getParameter("receipt_data");
			String receipt_Acount = request.getParameter("Acount");

			String body = "{\"receipt-data\":\"" + receipt_data + "\"}";

			if (receipt_data != null) {
				String result = Util.doPost(ServerUrl, body);

				JSONTokener jsonParser = new JSONTokener(result);
				// 此时还未读取任何json文本，直接读取就是一个JSONObject对象。
				JSONObject resultJson = (JSONObject) jsonParser.nextValue();
				// 接下来的就是JSON对象的操作了
				ResponseReceived Response = new ResponseReceived(
						resultJson.getString("status"),
						resultJson.getString("receipt"));

				//
				JSONTokener receipt_jsonTokener = new JSONTokener(
						resultJson.getString("receipt"));
				JSONObject receipt_resultJson = (JSONObject) receipt_jsonTokener
						.nextValue();

				String receipt = null;

				String logMsg = "pid=" + SdkBillingServer.PID_IOS;
				logMsg += "&orderid="
						+ receipt_resultJson.getString("transaction_id");
				logMsg += "&payway=0";
				logMsg += "&amount="
						+ receipt_resultJson.getString("purchase_date");
				logMsg += "&account="
						+ receipt_resultJson.getString("product_id");
				logMsg += "&serverid=";
				logMsg += "&recodedate=" + MyDateFormart.getFormatDate();

				if (Response.getStatus().equals("0")) {
					receipt = XuanQu.ios.Util.getFromBASE64(Response
							.getReceipt());

					String paymentString[] = receipt_Acount.split("_");

					String nAccount = paymentString[0];
					String serverid = paymentString[1];
					// XQServerChargeOffline msgChargeOffline = new
					// XQServerChargeOffline();
					// msgChargeOffline.nPid = CServerMain.PID_IOS;// 91平台
					// msgChargeOffline.strOrderId = receipt_resultJson
					// .getString("transaction_id");
					// msgChargeOffline.nPcId = 0;
					// msgChargeOffline.nAmount = ios.Paycoin(receipt_resultJson
					// .getString("product_id"));
					// msgChargeOffline.setAccountID(nAccount);
					// CServerConnectMgr.getConnectMgr().sendMessageToAccount(
					// msgChargeOffline);
					// 成功
					logMsg += "&cperror=200";
					logger.debug("<errcode=200&errmsg=接收成功&" + logMsg + ">");
					resultMessage = "{\"ErrorCode\":\"1\",\"ErrorDesc\":\"订单处理成功\"} ";
				} else {
					logMsg += "&cperror=404";
					logger.debug("<errcode=-1&errmsg=订单无效&" + logMsg + ">");
					resultMessage = "{\"ErrorCode\":\"0\",\"ErrorDesc\":\"订单无效\"} ";
				}
			} else {
				// 失败
				String logMsgNull = "pid=" + SdkBillingServer.PID_IOS;
				logMsgNull += "&orderid=-1";
				logMsgNull += "&payway=-1";
				logMsgNull += "&amount=-1";
				logMsgNull += "&account=-1";
				logMsgNull += "&serverid=";
				logMsgNull += "&recodedate=" + MyDateFormart.getFormatDate();

				logMsgNull += "&cperror=-1";
				logger.debug("<errcode=-1&errmsg=request为空&" + logMsgNull + ">");
				resultMessage = "{\"ErrorCode\":\"0\",\"ErrorDesc\":\"接收失败\"} ";
			}
		} catch (Exception e) {
			// System.out.println("接收支付回调通知的参数失败");
			// 失败
			String logMsgError = "pid=" + SdkBillingServer.PID_IOS;
			logMsgError += "&orderid=0";
			logMsgError += "&payway=0";
			logMsgError += "&amount=0";
			logMsgError += "&account=0";
			logMsgError += "&serverid=";
			logMsgError += "&recodedate=" + MyDateFormart.getFormatDate();
			logMsgError += "&cperror=0";
			logger.debug("<errcode=0&errmsg=异常&" + logMsgError + ">");
			// 失败
			resultMessage = "{\"ErrorCode\":\"0\",\"ErrorDesc\":\"接收失败\"} ";
		}

		if (response != null) {
			response.appendBody(resultMessage);
			session.write(response).addListener(IoFutureListener.CLOSE);
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
