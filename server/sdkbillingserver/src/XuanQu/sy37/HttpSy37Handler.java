package XuanQu.sy37;

import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.Map;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

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
public class HttpSy37Handler extends IoHandlerAdapter {
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
		System.out.println("======msg======"+msg);
		
		String username  = msg.getParameter("username");
		String change_id  = msg.getParameter("change_id");
		String money  = msg.getParameter("money");
		String hash  = msg.getParameter("hash");
		String object  = msg.getParameter("object");
		System.out.println("======hash======"+hash);
//		String sign  = msg.getParameter("sign");
//		String server  = msg.getParameter("server");
//		String _user="";
//		try {
//			_user=URLEncoder.encode(user, "utf-8");
//		} catch (UnsupportedEncodingException e) {
//			// TODO Auto-generated catch block
//			e.printStackTrace();
//		}
//		String ip  = msg.getParameter("ip");
//		String ext  = msg.getParameter("ext");
//		String roleid  = msg.getParameter("roleid");
		
		
    	String key="";
		try {
			key = "a27958248ed0ed37aec3c6218a9d13e0";
		} catch (Exception e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		} 
		String str=username+"|"+change_id+"|"+money+"|"+key;
		System.out.println("==========str==========="+str);
		String signMd5 = Util.getMD5(str);
		System.out.println("==========signMd5==========="+signMd5);

		HttpResponseMessage response = new HttpResponseMessage();
		response.setResponseCode(HttpResponseMessage.HTTP_STATUS_SUCCESS);

		String _result = "";

		String _userMsg[] = object.split("_");
		String nAccount = _userMsg[0];
		String serverid = _userMsg[1];
		String PID=_userMsg[2];
		String _time=_userMsg[3];
		String _order=PID+"_"+_time;
		
		Double dAmount = Double.parseDouble(money);

		String logMsg = "pid=" + SdkBillingServer.PID_SY37;
		logMsg += "&orderid=" + _order;
		logMsg += "&payway=0";
		logMsg += "&amount=" + (int) (dAmount * 100);
		logMsg += "&account=" + nAccount;
		logMsg += "&serverid=" + serverid;
		logMsg += "&recodedate=" + MyDateFormart.getFormatDate();
		if (signMd5.equals(hash)) {
			// String paymentString[] = mark.split("_");

			_result = HttpSendPartBillServer.sendBillServerByServerId(nAccount,
					(int) (dAmount*100), _order, "0",
					SdkBillingServer.PID_SY37, "", serverid);
			response.appendBody("1");
			session.write(response).addListener(IoFutureListener.CLOSE);

			// 成功
			logMsg += "&cperror=200";
			logger.debug("<errcode=1&errmsg=&" + logMsg + ">");
		} else {
			response.appendBody("0");
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
