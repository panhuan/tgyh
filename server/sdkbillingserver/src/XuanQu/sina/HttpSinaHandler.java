package XuanQu.sina;

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
public class HttpSinaHandler extends IoHandlerAdapter {
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
		
		String payAmount = request.getParameter("payAmount");
		String ext1 = request.getParameter("ext1");
		
		String orderId = request.getParameter("orderId");
		String signMsg = request.getParameter("signMsg");
		String payType = request.getParameter("payType");
//		String serverid = request.getParameter("ext2");
		String content = getVerifyData(request);
		
		String paymentString[] = ext1.split("_");
		String nAccount = paymentString[0];
		String serverid = paymentString[1];
		double dAmount=Double.parseDouble(payAmount);
		String _result = "";
		//#AppKey=rDU8yL4cenwYM6qd@ZVGQ6sT6a8JU4sPU#WtMAMe9AP7VDmNpP
		try {
			String payKey=Util.getConfig("AppKey");
			String signMsg2 = SignUtil.getSign(payKey, "MD5", content);
			
			String logMsg = "pid=" + SdkBillingServer.PID_DDL;
			logMsg += "&orderid=" + orderId;
			logMsg += "&payway=" + 0;
			logMsg += "&amount=" + (int) (dAmount * 1);
			logMsg += "&account=" + nAccount;
			logMsg += "&serverid=" + serverid;
			logMsg += "&recodedate=" + MyDateFormart.getFormatDate();
			
			if(signMsg.equals(signMsg2)){

				_result = HttpSendPartBillServer
							.sendBillServerByServerId(nAccount, (int) (dAmount * 1), orderId,
									"0", SdkBillingServer.PID_DDL, "", serverid);
				
				if (response != null && "success".equals(_result)) {
					response.appendBody("<result>1</result><redirecturl></redirecturl>");
					session.write(response).addListener(IoFutureListener.CLOSE);
				} else {
					response.appendBody("<result>0</result><redirecturl></redirecturl>");
					session.write(response).addListener(IoFutureListener.CLOSE);
				}
				// 成功

				logMsg += "&cperror=200";
				logger.debug("<errcode=1&errmsg=&" + logMsg + ">");
			}else{
				response.appendBody("FAILURE");
				if (response != null) {
					session.write(response).addListener(IoFutureListener.CLOSE);
				}
				// Sign无效
				logMsg += "&cperror=404";
				logger.debug("<errcode=0&errmsg=Sign无效&" + logMsg + ">");
			}
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	private String getVerifyData(HttpRequestMessage request) {
		String merchantAcctId = request.getParameter("merchantAcctId");
		String version = request.getParameter("version");
		String language = request.getParameter("language");
		String signType = request.getParameter("signType");
		String payType = request.getParameter("payType");
		String bankId = request.getParameter("bankId");
		String orderId = request.getParameter("orderId");
		String orderTime = request.getParameter("orderTime");
		String orderAmount = request.getParameter("orderAmount");
		String dealId = request.getParameter("dealId");
		String bankDealId = request.getParameter("bankDealId");
		String dealTime = request.getParameter("dealTime");
		String payAmount = request.getParameter("payAmount");
		String fee = request.getParameter("fee");
		String ext1 = request.getParameter("ext1");
		String ext2 = request.getParameter("ext2");
		String payResult = request.getParameter("payResult");
		String payIp = request.getParameter("payIp"); 
		String errCode = request.getParameter("errCode");

		StringBuilder builder = new StringBuilder();
		if (merchantAcctId != null && !"".equals(merchantAcctId)) {
			builder.append("merchantAcctId").append('=').append(merchantAcctId);
		}
		if (version != null && !"".equals(version)) {
			builder.append('&').append("version").append('=').append(version);
		}
		if (language != null && !"".equals(language)) {
			builder.append('&').append("language").append('=').append(language);
		}
		if (signType != null && !"".equals(signType)) {
			builder.append('&').append("signType").append('=').append(signType);
		}
		if (payType != null && !"".equals(payType)) {
			builder.append('&').append("payType").append('=').append(payType);
		}
		if (bankId != null && !"".equals(bankId)) {
			builder.append('&').append("bankId").append('=').append(bankId);
		}
		if (orderId != null && !"".equals(orderId)) {
			builder.append('&').append("orderId").append('=').append(orderId);
		}
		if (orderTime != null && !"".equals(orderTime)) {
			builder.append('&').append("orderTime").append('=').append(orderTime);
		}
		if (orderAmount != null && !"".equals(orderAmount)) {
			builder.append('&').append("orderAmount").append('=').append(orderAmount);
		}
		if (dealId != null && !"".equals(dealId)) {
			builder.append('&').append("dealId").append('=').append(dealId);
		}
		if (bankDealId != null && !"".equals(bankDealId)) {
			builder.append('&').append("bankDealId").append('=').append(bankDealId);
		}
		if (dealTime != null && !"".equals(dealTime)) {
			builder.append('&').append("dealTime").append('=').append(dealTime);
		}
		if (payAmount != null && !"".equals(payAmount)) {
			builder.append('&').append("payAmount").append('=').append(payAmount);
		}
		if (fee != null && !"".equals(fee)) {
			builder.append('&').append("fee").append('=').append(fee);
		}
		if (ext1 != null && !"".equals(ext1)) {
			builder.append('&').append("ext1").append('=').append(ext1);
		}
		if (ext2 != null && !"".equals(ext2)) {
			builder.append('&').append("ext2").append('=').append(ext2);
		}
		if (payResult != null && !"".equals(payResult)) {
			builder.append('&').append("payResult").append('=').append(payResult);
		}
		if (payIp != null && !"".equals(payIp)) {
			builder.append('&').append("payIp").append('=').append(payIp);
		}
		if (errCode != null && !"".equals(errCode)) {
			builder.append('&').append("errCode").append('=').append(errCode);
		}
		String content = builder.toString();
		return content;
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
