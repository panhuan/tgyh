package XuanQu.cmcc;

import java.util.HashMap;

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


public class HttpCMCCHandler extends IoHandlerAdapter {
	private static final Logger logger = LoggerFactory.getLogger("charge");

	// 当一个客端端连结进入时
	@Override
	public void sessionOpened(IoSession session) {
		// set idle time to 60 seconds
		session.getConfig().setIdleTime(IdleStatus.BOTH_IDLE, 60);

		System.out.println("one Clinet Connect : " + session.getRemoteAddress());
	}

	// 当一个客户端关闭时
	@Override
	public void sessionClosed(IoSession session) {
		System.out.println("one Clinet Disconnect :" + session.getRemoteAddress());
	}

	@Override
	public void messageReceived(IoSession session, Object message) {

		System.out.println("cmcc messageReceived!!");
		
		HttpRequestMessage msg 	= (HttpRequestMessage) message;
		String app_key 			= msg.getParameter("app_key");
		String product_id 		= msg.getParameter("product_id");
		String amount 			= msg.getParameter("amount");
		String app_uid 			= msg.getParameter("app_uid");
		String app_ext1 		= msg.getParameter("app_ext1");
		String app_ext2 		= msg.getParameter("app_ext2");
		String user_id 			= msg.getParameter("user_id");
		String order_id 		= msg.getParameter("order_id");
		String gateway_flag 	= msg.getParameter("gateway_flag");
		String sign_type 		= msg.getParameter("sign_type");
		String app_order_id 	= msg.getParameter("app_order_id");
		String sign_return 		= msg.getParameter("sign_return");
		String sign 			= msg.getParameter("sign");

		// 特殊字符被转了, 比如# --> %23, 反转一下 zhanghuaming
		app_order_id = java.net.URLDecoder.decode(app_order_id);
		
		int nAmount = Integer.parseInt(amount);
		
		// 把订单都发送到服务器(gc)
		String serverid = "1";

		StringBuilder logMsg = new StringBuilder();
		logMsg.append("&platformid=");
		logMsg.append(SdkBillingServer.PID_CMCC);
		logMsg.append("&app_key=");
		logMsg.append(app_key);
		logMsg.append("&product_id=");
		logMsg.append(product_id);
		logMsg.append("&amount=");
		logMsg.append(amount);
		logMsg.append("&app_uid=");
		logMsg.append(app_uid);
		logMsg.append("&user_id=");
		logMsg.append(user_id);
		logMsg.append("&order_id=");
		logMsg.append(order_id);
		logMsg.append("&gateway_flag=");
		logMsg.append(gateway_flag);
		logMsg.append("&sign_type=");
		logMsg.append(sign_type);
		logMsg.append("&app_order_id=");
		logMsg.append(app_order_id);
		logMsg.append("&sign_return=");
		logMsg.append(sign_return);
		logMsg.append("&sign=");
		logMsg.append(sign);
		logMsg.append("&app_ext1=");
		logMsg.append(app_ext1);
		logMsg.append("&app_ext2=");
		logMsg.append(app_ext2);
		logMsg.append("&serverid=");
		logMsg.append(serverid);
		
		try {
			
			HashMap<String,String> paramMap = new HashMap<String,String>();
			paramMap.put("app_key", app_key);
			paramMap.put("product_id", product_id);
			paramMap.put("amount", amount);
			paramMap.put("app_uid", app_uid);
			paramMap.put("user_id", user_id);
			paramMap.put("order_id", order_id);
			paramMap.put("gateway_flag", gateway_flag);
			paramMap.put("sign_type", sign_type);
			paramMap.put("app_order_id", app_order_id);
			paramMap.put("sign_return", sign_return);
			paramMap.put("sign", sign);
			
			// deliver to GameServer
			String result = HttpSendPartBillServer.sendBillServerByServerId(
				app_uid, 
				nAmount, 
				app_order_id,
				"0", 
				SdkBillingServer.PID_CMCC, 
				"", 
				serverid
				);
			
			// 回复360
			HttpResponseMessage response = new HttpResponseMessage();
			response.setResponseCode(HttpResponseMessage.HTTP_STATUS_SUCCESS);
			if (response != null && (result != null || !"".equals(result))) {
				response.appendBody("ok");
				session.write(response).addListener(IoFutureListener.CLOSE);
			}
			
			// 成功
			logMsg.insert(0, "<errcode=1&errmsg='success'");
			logMsg.append("&cperror=200>");
			logger.debug(logMsg.toString());
			
		} finally {
			
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
