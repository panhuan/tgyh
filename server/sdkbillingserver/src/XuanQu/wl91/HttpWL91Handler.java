package XuanQu.wl91;

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
import XuanQu.multipleServer.HttpSendPartBillServer;
import XuanQu.util.MyDateFormart;
import XuanQu.wl91.model.PayCallbackNoStatusResponse;

/**
 * @author banshuai
 * 
 */
public class HttpWL91Handler extends IoHandlerAdapter {
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
			PayCallbackNoStatusResponse pcResponse = Util
					.resolveResponseParamter(request);

			if (pcResponse != null) {
				String AppKey = "";
				String AppId = "";
				
				String paymentString[] = pcResponse.getNote().split("_");

				String nAccount = paymentString[0];
				String serverid = paymentString[1];
				
				if(pcResponse.getNote().contains("Andr")){
					AppKey = Util.getConfig("AppKey_Android");
					AppId = Util.getConfig("AppId_Android");
				} else {
					AppKey = Util.getConfig("AppKey");
					AppId = Util.getConfig("AppId");
				}
				String decoderProductName = "";
				String decoderGoodsInfo = "";
				String decoderCreateTime = "";
				try {
					decoderProductName = java.net.URLDecoder.decode(
							pcResponse.getProductName(), "utf-8");
					decoderGoodsInfo = java.net.URLDecoder.decode(
							pcResponse.getGoodsInfo(), "utf-8");
					decoderCreateTime = java.net.URLDecoder.decode(
							pcResponse.getCreateTime(), "utf-8");
				} catch (UnsupportedEncodingException e) {
					e.printStackTrace();
				}

				String signStr = Util.getMD5(pcResponse.getAppId()
						+ pcResponse.getAct() + decoderProductName
						+ pcResponse.getConsumeStreamId()
						+ pcResponse.getCooOrderSerial() + pcResponse.getUin()
						+ pcResponse.getGoodsId() + decoderGoodsInfo
						+ pcResponse.getGoodsCount()
						+ pcResponse.getOriginalMoney()
						+ pcResponse.getOrderMoney() + pcResponse.getNote()
						+ pcResponse.getPayStatus() + decoderCreateTime
						+ AppKey);

				String logMsg = "pid=" + SdkBillingServer.PID_WL91;
				logMsg += "&orderid=" + pcResponse.getCooOrderSerial();
				logMsg += "&payway=0";
				logMsg += "&amount="
						+ (int) (Double.parseDouble(pcResponse.getOrderMoney()) * 100);
				logMsg += "&account=" + nAccount;
				logMsg += "&serverid=" + serverid;
				logMsg += "&recodedate=" + MyDateFormart.getFormatDate();

				if (signStr.equals(pcResponse.getSign())) {
					String strAppid = pcResponse.getAppId().trim();

					if ("0".equals(pcResponse.getPayStatus())) {
						// 失败
						logMsg += "&cperror=404";
						logger.debug("<errcode=0&errmsg=接收失败&" + logMsg + ">");
						resultMessage = "{\"ErrorCode\":\"0\",\"ErrorDesc\":\"接收失败\"} ";
					} else if ("1".equals(pcResponse.getPayStatus())) {

						_result = HttpSendPartBillServer
								.sendBillServerByServerId(nAccount,
										(int)Double.parseDouble(pcResponse
												.getOrderMoney()) * 100,
										pcResponse.getCooOrderSerial(), "0",
										SdkBillingServer.PID_WL91, "",
										serverid);

						logMsg += "&cperror=200";
						logger.debug("<errcode=1&errmsg=接收成功&" + logMsg + ">");
						
						if((_result != null || !"".equals(_result)) && (_result.equals("success"))) {
							resultMessage = "{\"ErrorCode\":\"1\",\"ErrorDesc\":\"接收成功\"} ";
						} else {
							resultMessage = "{\"ErrorCode\":\"0\",\"ErrorDesc\":\"接收失败\"} ";
						}
						
					} else if (strAppid.equals(AppId)) {
						// AppId无效
						logMsg += "&cperror=404";
						logger.debug("<errcode=2&errmsg=AppId无效&" + logMsg
								+ ">");
						resultMessage = "{\"ErrorCode\":\"2\",\"ErrorDesc\":\"AppId无效\"} ";
					}
				} else {
					logMsg += "&cperror=500";
					logger.debug("<errcode=5&errmsg=Sign无效&" + logMsg + ">");
					// Sign无效
					resultMessage = "{\"ErrorCode\":\"5\",\"ErrorDesc\":\"Sign无效\"} ";
				}
			} else {
				// 失败
				String logMsgNull = "pid=" + SdkBillingServer.PID_WL91;
				logMsgNull += "&orderid=-1";
				logMsgNull += "&payway=-1";
				logMsgNull += "&amount=-1";
				logMsgNull += "&account=-1";
				logMsgNull += "&serverid=-1";
				logMsgNull += "&recodedate=" + MyDateFormart.getFormatDate();
				logMsgNull += "&cperror=-1";

				logger.debug("<errcode=-1&errmsg=request为空&" + logMsgNull + ">");
				resultMessage = "{\"ErrorCode\":\"0\",\"ErrorDesc\":\"接收失败\"} ";
			}
		} catch (Exception e) {
			// 失败
//			String logMsgError = "pid=" + CServerMain.PID_WL91;
//			logMsgError += "&orderid=0";
//			logMsgError += "&payway=0";
//			logMsgError += "&amount=0";
//			logMsgError += "&account=0";
//			logMsgError += "&recodedate=" + MyDateFormart.getFormatDate();
//			logMsgError += "&cperror=0";
//			logger.debug("<errcode=0&errmsg=异常&" + logMsgError + ">");
//			// 失败
//			resultMessage = "{\"ErrorCode\":\"0\",\"ErrorDesc\":\"接收失败\"} ";
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
