package XuanQu.miui;

import java.io.UnsupportedEncodingException;

import org.apache.mina.core.future.IoFutureListener;
import org.apache.mina.core.service.IoHandlerAdapter;
import org.apache.mina.core.session.IdleStatus;
import org.apache.mina.core.session.IoSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import XuanQu.RWGate.SdkBillingServer;
import XuanQu.httpserver.HttpRequestMessage;
import XuanQu.httpserver.HttpResponseMessage;
import XuanQu.miui.model.PayCallbackResponse;
import XuanQu.multipleServer.HttpSendPartBillServer;
import XuanQu.util.MyDateFormart;

/**
 * @author banshuai
 * 
 */
public class HttpMIUIHandler extends IoHandlerAdapter {
	private static final Logger logger = LoggerFactory.getLogger("charge");

	@Override
	public void sessionOpened(IoSession session) {
		// set idle time to 60 seconds
		session.getConfig().setIdleTime(IdleStatus.BOTH_IDLE, 60);
	}

	// 游戏合作商编号
	private static int AppId = 0;
	// 游戏合作商key
	private static String AppKey = "";

	// 收到的消息处理
	@Override
	public void messageReceived(IoSession session, Object message) {
		HttpResponseMessage response = new HttpResponseMessage();
		response.setResponseCode(HttpResponseMessage.HTTP_STATUS_SUCCESS);

		try {
			AppId = Integer.valueOf(Util.getConfig("AppId"));
			AppKey = Util.getConfig("AppKey");
		} catch (NumberFormatException e1) {
			e1.printStackTrace();
		} catch (Exception e1) {
			e1.printStackTrace();
		}

		HttpRequestMessage request = (HttpRequestMessage) message;
		String resultMessage = "";
		PayCallbackResponse pcResponse = Util.resolveResponseParamter(request);

		if (pcResponse != null) {
			String productName = pcResponse.getProductName();
			String payTime = pcResponse.getPayTime();
			// encoding
			try {
				productName = java.net.URLDecoder.decode(productName, "utf-8");
				payTime = java.net.URLDecoder.decode(payTime, "utf-8");
			} catch (UnsupportedEncodingException e) {
				e.printStackTrace();
			}

			String signStr = "appId=" + pcResponse.getAppId() + "&cpOrderId="
					+ pcResponse.getCpOrderId() + "&cpUserInfo="
					+ pcResponse.getCpUserInfo() + "&orderId="
					+ pcResponse.getOrderId() + "&orderStatus="
					+ pcResponse.getOrderStatus() + "&payFee="
					+ pcResponse.getPayFee() + "&payTime=" + payTime
					+ "&productCode=" + pcResponse.getProductCode()
					+ "&productCount=" + pcResponse.getProductCount()
					+ "&productName=" + productName + "&uid="
					+ pcResponse.getUid();
			String _signStr = "";

			try {
				_signStr = HmacSHA1Encryption.HmacSHA1Encrypt(signStr, AppKey);
			} catch (Exception e) {
				e.printStackTrace();
			}

			String paymentString[] = pcResponse.getCpUserInfo().split(
					"_");

			String nAccount = paymentString[0];
			String serverid = paymentString[1];

			String logMsg = "pid=" + SdkBillingServer.PID_MIUI;
			logMsg += "&orderid=" + pcResponse.getCpOrderId();
			logMsg += "&payway=0";
			logMsg += "&amount="
					+ (int) (Double.parseDouble(pcResponse.getPayFee()));
			logMsg += "&account=" + nAccount;
			logMsg += "&serverid=" + serverid;
			logMsg += "&recodedate=" + MyDateFormart.getFormatDate();

			String _result = "";
			if (_signStr.equals(pcResponse.getSignature())) {
				String strAppid = AppId + "";
				strAppid = strAppid + "";

				if ("TRADE_SUCCESS".equals(pcResponse.getOrderStatus())) {

					_result = HttpSendPartBillServer
							.sendBillServerByServerId(nAccount, (int) (Double
									.parseDouble(pcResponse.getPayFee())),
									pcResponse.getCpOrderId(), "0",
									SdkBillingServer.PID_MIUI, "",
									serverid);

					// 成功
					logMsg += "&cperror=200";
					logger.debug("<errcode=200&errmsg=接收成功&" + logMsg + ">");
					resultMessage = "{\"errcode\":\"200\",\"errMsg\":\"接收成功\"} ";
				} else if (strAppid.equals(pcResponse.getAppId())) {
					// AppId无效
					logMsg += "&cperror=404";
					logger.debug("<errcode=1515&errmsg=AppId无效&" + logMsg + ">");
					resultMessage = "{\"errcode\":\"1515\",\"errMsg\":\"AppId无效\"} ";
				}
			} else {
				// Sign无效
				logMsg += "&cperror=404";
				logger.debug("<errcode=1525&errmsg=Sign无效&" + logMsg + ">");
				resultMessage = "{\"errcode\":\"1525\",\"errMsg\":\"Sign无效\"} ";
			}

			response.appendBody(resultMessage);
			if (response != null && (_result != null || !"".equals(_result))) {
				session.write(response).addListener(IoFutureListener.CLOSE);
			} else {
				// 失败
				resultMessage = "{\"errcode\":\"1525\",\"errMsg\":\"Sign无效\"} ";

				response.appendBody(resultMessage);
				if (response != null) {
					session.write(response).addListener(IoFutureListener.CLOSE);
				}
			}
		} else {
			// System.out.println("接口返回异常");
			// 失败
			String logMsgNull = "pid=" + SdkBillingServer.PID_MIUI;
			logMsgNull += "&orderid=-1";
			logMsgNull += "&payway=-1";
			logMsgNull += "&amount=-1";
			logMsgNull += "&account=-1";
			logMsgNull += "&serverid=";
			logMsgNull += "&recodedate=" + MyDateFormart.getFormatDate();

			logMsgNull += "&cperror=-1";
			logger.debug("<errcode=-1&errmsg=request为空&" + logMsgNull + ">");
			// 失败
			resultMessage = "{\"errcode\":\"1525\",\"errMsg\":\"Sign无效\"} ";

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
