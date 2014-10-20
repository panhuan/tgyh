package XuanQu.vivo;

import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.util.HashMap;
import java.util.Map;

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

public class HttpVivoHandler extends IoHandlerAdapter {
	private static final Logger logger = LoggerFactory.getLogger("charge");

	@Override
	public void sessionOpened(IoSession session) {
		// set idle time to 60 seconds
		session.getConfig().setIdleTime(IdleStatus.BOTH_IDLE, 60);
	}

	@Override
	public void messageReceived(IoSession session, Object message) {

		HttpRequestMessage msg = (HttpRequestMessage) message;

		String vivoOrder  = msg.getParameter("vivoOrder");
		String storeOrder = msg.getParameter("storeOrder");
		String signMethod  = msg.getParameter("signMethod");
		String respMsg  = msg.getParameter("respMsg");
		String signature  = msg.getParameter("signature");
		String channel  = msg.getParameter("channel");
		String orderAmount = msg.getParameter("orderAmount");
		String storeId = msg.getParameter("storeId");
		String channelFee   = msg.getParameter("channelFee");
		String respCode   = msg.getParameter("respCode");
		
		Map<String,String> para = new HashMap<String, String>();
    	para.clear();
    	
    	para.put("vivoOrder", vivoOrder);
    	para.put("storeOrder", storeOrder);
    	para.put("signMethod", signMethod);
    	
    	String _respMsg="";
    	try {
    		_respMsg=URLDecoder.decode(respMsg, "utf-8");
		} catch (UnsupportedEncodingException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		para.put("respMsg", _respMsg);
    	para.put("signature", signature);
    	para.put("channel", channel);
    	para.put("orderAmount", orderAmount);
    	para.put("storeId", storeId);
    	para.put("channelFee", channelFee);
    	para.put("respCode", respCode);
    	
    	String key="";
		try {
			key = Util.getConfig("KEY");
		} catch (Exception e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		} 
		String sign = VivoSignUtils.getVivoSign(para, key);
    	boolean verify = VivoSignUtils.verifySignature(para, key);
		

		HttpResponseMessage response = new HttpResponseMessage();
		response.setResponseCode(HttpResponseMessage.HTTP_STATUS_SUCCESS);

		String _result = "";

		String userMsg[] = storeOrder.split("_");
		String nAccount = userMsg[0];
		String serverid = userMsg[1];
		Double dAmount = Double.parseDouble(orderAmount);

		String logMsg = "pid=" + SdkBillingServer.PID_VIVO;
		logMsg += "&orderid=" + storeOrder;
		logMsg += "&payway=0";
		logMsg += "&amount=" + (int) (dAmount * 100);
		logMsg += "&account=" + nAccount;
		logMsg += "&serverid=" + serverid;
		logMsg += "&recodedate=" + MyDateFormart.getFormatDate();
		if (verify) {
			// String paymentString[] = mark.split("_");

			_result = HttpSendPartBillServer.sendBillServerByServerId(nAccount,
					(int) (dAmount*100), storeOrder, "0",
					SdkBillingServer.PID_VIVO, "", serverid);
			response.appendBody("200");
			session.write(response).addListener(IoFutureListener.CLOSE);

			// 成功
			logMsg += "&cperror=200";
			logger.debug("<errcode=1&errmsg=&" + logMsg + ">");
		} else {
			response.appendBody("-1");
			if (response != null) {
				session.write(response).addListener(IoFutureListener.CLOSE);
			}

			// Sign无效
			logMsg += "&cperror=404";
			logger.debug("<errcode=500&errmsg=Sign无效&" + logMsg + ">");
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
