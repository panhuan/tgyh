package XuanQu.UCWeb;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.InputStreamReader;
import java.text.DecimalFormat;

import org.apache.mina.core.future.IoFutureListener;
import org.apache.mina.core.service.IoHandlerAdapter;
import org.apache.mina.core.session.IdleStatus;
import org.apache.mina.core.session.IoSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import XuanQu.RWGate.SdkBillingServer;
import XuanQu.UCWeb.model.PayCallbackResponse;
import XuanQu.httpserver.HttpRequestMessage;
import XuanQu.httpserver.HttpResponseMessage;
import XuanQu.multipleServer.HttpSendPartBillServer;
import XuanQu.util.MyDateFormart;

public class HttpUCWebHandler extends IoHandlerAdapter {
	private static final Logger logger = LoggerFactory.getLogger("charge");

	@Override
	public void sessionOpened(IoSession session) {
		// set idle time to 60 seconds
		session.getConfig().setIdleTime(IdleStatus.BOTH_IDLE, 60);
	}

	@Override
	public void messageReceived(IoSession session, Object message) {

		HttpRequestMessage request = (HttpRequestMessage) message;

		HttpResponseMessage response = new HttpResponseMessage();
		response.setResponseCode(HttpResponseMessage.HTTP_STATUS_SUCCESS);
		int cpId = 0;
		String apiKey = "";

		try {
			cpId = Integer.valueOf(Util.getConfig("cpId"));
			apiKey = Util.getConfig("apiKey");
		} catch (NumberFormatException e2) {
			e2.printStackTrace();
		} catch (Exception e2) {
			e2.printStackTrace();
		}

//		logger.debug("cpId=" + cpId);
		
		BufferedReader in = null;
		try {
			String strUCBody = request.getParameter("ucbody");
			ByteArrayInputStream inputbody = new ByteArrayInputStream(
					strUCBody.getBytes());

			in = new BufferedReader(new InputStreamReader(inputbody, "utf-8"));
			String ln;
			StringBuffer stringBuffer = new StringBuffer();
			while ((ln = in.readLine()) != null) {
				stringBuffer.append(ln);
				stringBuffer.append("\r\n");
			}

			PayCallbackResponse rsp = (PayCallbackResponse) Util.decodeJson(
					stringBuffer.toString(), PayCallbackResponse.class);// 反序列化
			if (rsp != null) {

				DecimalFormat df = new DecimalFormat("0.00");
				String strAmount = df.format(rsp.getData().getAmount());

				String signSource = cpId + "amount=" + strAmount
						+ "callbackInfo=" + rsp.getData().getCallbackInfo()
						+ "failedDesc=" + rsp.getData().getFailedDesc()
						+ "gameId=" + rsp.getData().getGameId() + "orderId="
						+ rsp.getData().getOrderId() + "orderStatus="
						+ rsp.getData().getOrderStatus() + "payWay="
						+ rsp.getData().getPayWay() + "serverId="
						+ rsp.getData().getServerId() + "ucid="
						+ rsp.getData().getUcid() + apiKey;
				String sign = Util.getMD5Str(signSource);

				String paymentString[] = rsp.getData().getCallbackInfo().split("_");
				String nAccount = paymentString[0];
				String serverid = paymentString[1];
				
				String logMsg = "pid=" + SdkBillingServer.PID_UCWEB;
				logMsg += "&orderid=" + rsp.getData().getOrderId();
				logMsg += "&payway=" + rsp.getData().getPayWay();
				logMsg += "&amount=" + (int) (rsp.getData().getAmount() * 100);
				logMsg += "&account=" + nAccount;
				logMsg += "&serverid=" + serverid;
				logMsg += "&recodedate=" + MyDateFormart.getFormatDate();

				String orderStatus = rsp.getData().getOrderStatus().trim();
				String failedDesc = rsp.getData().getFailedDesc();
				
				String strMessage = "";
				String _result = "";
				
//				logger.debug("account=" + nAccount);
//				logger.debug("serverid=" + serverid);
				
				if (sign.equals(rsp.getSign())) {
					if ("S".equals(orderStatus)) {

						_result = HttpSendPartBillServer
								.sendBillServerByServerId(nAccount, (int) (rsp
										.getData().getAmount() * 100), rsp
										.getData().getOrderId(), "0",
										SdkBillingServer.PID_UCWEB, "", serverid);

//						logger.debug("_result=" + _result);
						// 成功
						logMsg += "&cperror=200";
						logger.debug("<errcode=" + orderStatus + "&errmsg="
								+ failedDesc + "&" + logMsg + ">");
						strMessage = "SUCCESS";
					} else if ("F".equals(orderStatus)) {
						// 失败
						logMsg += "&cperror=404";
						logger.debug("<errcode=" + orderStatus + "&errmsg="
								+ failedDesc + "&" + logMsg + ">");
						strMessage = "SUCCESS";
					}
				} else {
					// Sign无效
					logMsg += "&cperror=500";
					logger.debug("<errcode=500&errmsg=Sign无效&" + logMsg + ">");
					strMessage = "FAILURE";// 返回给sdk server的响应内容
											// ,对于重复多次通知失败的订单,请参考文档中通知机制。
				}
				if (response != null
						&& (_result != null || !"".equals(_result))) {
					response.appendBody(strMessage);
					session.write(response).addListener(IoFutureListener.CLOSE);
				}
			} else {
				String logMsgNull = "pid=" + SdkBillingServer.PID_UCWEB;
				logMsgNull += "&orderid=-1";
				logMsgNull += "&payway=-1";
				logMsgNull += "&amount=-1";
				logMsgNull += "&account=-1";
				logMsgNull += "&serverid=";
				logMsgNull += "&recodedate=" + MyDateFormart.getFormatDate();
				logMsgNull += "&cperror=-1";

				logger.debug("<errcode=-1&errmsg=request为空&" + logMsgNull + ">");
			}
		} catch (Exception e) {
			// System.out.println("接收支付回调通知的参数失败");
			// 失败
			String logMsgError = "pid=" + SdkBillingServer.PID_UCWEB;
			logMsgError += "&orderid=0";
			logMsgError += "&payway=0";
			logMsgError += "&amount=0";
			logMsgError += "&account=0";
			logMsgError += "&serverid=0";
			logMsgError += "&recodedate=" + MyDateFormart.getFormatDate();
			logMsgError += "&cperror=0";
			logger.debug("<errcode=0&errmsg=异常&" + logMsgError + ">");
		} finally {
			try {
				if (null != in)
					in.close();
				in = null;
			} catch (Exception e1) {
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
