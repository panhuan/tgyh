package XuanQu.wandoujia;

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

/**
 * @author banshuai
 * 
 */
public class HttpWanDouJiaHandler extends IoHandlerAdapter {
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

		String resultMessage = "";
		String _result = "";
		try {

			String content = URLDecoder.decode(request.getParameter("content"));
			
			String signType = request.getParameter("signType");
			String sign = URLDecoder.decode(request.getParameter("sign"));

			boolean check = false;
			check = WandouRsa.doCheck(content, sign);

			if (check) {
				JSONTokener jsonParser = new JSONTokener(content);
				// 此时还未读取任何json文本，直接读取就是一个JSONObject对象。
				JSONObject resultJson = (JSONObject) jsonParser.nextValue();

				String timeStamp = resultJson.getString("timeStamp");
				String orderId = resultJson.getString("orderId");
				String money = resultJson.getString("money");
				String chargeType = resultJson.getString("chargeType");
				String appKeyId = resultJson.getString("appKeyId");
				String buyerId = resultJson.getString("buyerId");
				String out_trade_no = resultJson.getString("out_trade_no");
				String cardNo = resultJson.getString("cardNo");

				String paymentString[] = out_trade_no.split("_");
				String nAccount = paymentString[0];
				String serverid = paymentString[1];
				String myOrderid = out_trade_no;

				String logMsg = "pid=" + SdkBillingServer.PID_WANDOUJIA;
				logMsg += "&orderid=" + myOrderid;
				logMsg += "&payway=" + chargeType;
				logMsg += "&amount=" + (int) (Double.parseDouble(money));
				logMsg += "&account=" + nAccount;
				logMsg += "&serverid=" + serverid;
				logMsg += "&recodedate=" + MyDateFormart.getFormatDate();

				_result = HttpSendPartBillServer
						.sendBillServerByServerId(nAccount,
								(int) (Double.parseDouble(money)),
								myOrderid, "0", SdkBillingServer.PID_WANDOUJIA, "",
								serverid);
				
				System.currentTimeMillis();

				logMsg += "&cperror=200";
				logger.debug("<errcode=1&errmsg=接收成功&" + logMsg + ">");

				if ((_result != null || !"".equals(_result))
						&& (_result.equals("success"))) {
					resultMessage = "success";
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
