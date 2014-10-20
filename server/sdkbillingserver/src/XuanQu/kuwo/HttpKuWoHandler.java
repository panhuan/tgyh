package XuanQu.kuwo;




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

public class HttpKuWoHandler extends IoHandlerAdapter {
	private static final Logger logger = LoggerFactory.getLogger("charge");

	@Override
	public void sessionOpened(IoSession session) {
		// set idle time to 60 seconds
		session.getConfig().setIdleTime(IdleStatus.BOTH_IDLE, 60);
	}

	@Override
	public void messageReceived(IoSession session, Object message) {

		HttpRequestMessage msg = (HttpRequestMessage) message;
		
		// 12位支付密钥,当乐分配
		String paykey="";
		
		try {
			paykey = Util.getConfig("Paykey");
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		String sign = msg.getParameter("sign");

		String sid = msg.getParameter("serverid");
		String time = msg.getParameter("time");
		String userid = msg.getParameter("userid");
		String orderid = msg.getParameter("orderid");
	
		String amount = msg.getParameter("amount");
		String ext1 = msg.getParameter("ext1");
		String strs[]=ext1.split("_");
		String _orderid1=strs[0];
		String _orderid2= strs[1];
		String _orderid = _orderid1 + _orderid2;
		String nAccount = strs[2];
		String serverid = strs[3];
		
		String ext2 = msg.getParameter("ext2");
		
		String str ="serverid="+sid ;
		str+="&time="+time;
		str+="&userid="+userid;
		str+="&orderid="+orderid;
		str+="&amount="+amount;
		str+="&ext1="+ext1;
		str+="&ext2="+ext2;
		str+="&key="+paykey;
		
		String sig = Util.getMD5(str).toUpperCase();
		
		HttpResponseMessage response = new HttpResponseMessage();
		response.setResponseCode(HttpResponseMessage.HTTP_STATUS_SUCCESS);

		String _result = "";
		
		Double dAmount = new Double(amount).doubleValue();
		
		if (sig.equals(sign)){

			String logMsg = "pid=" + SdkBillingServer.PID_KUWO;
			logMsg += "&orderid=" + _orderid;
			logMsg += "&payway=0";
			logMsg += "&amount=" + (int) (dAmount * 100);
			logMsg += "&account=" + nAccount;
			logMsg += "&serverid=" + serverid;
			logMsg += "&recodedate=" + MyDateFormart.getFormatDate();
			
			_result = HttpSendPartBillServer
					.sendBillServerByServerId(nAccount, (int)(dAmount * 100), _orderid,
							"0", SdkBillingServer.PID_KUWO, "", serverid);
			
			if (response != null && (_result != null || !"".equals(_result))) {
				String result="0";
				response.appendBody(result);
				session.write(response).addListener(IoFutureListener.CLOSE);
			}

//			XQServerChargeOffline msgChargeOffline = new XQServerChargeOffline();
//			msgChargeOffline.nPid = CServerMain.PID_KUWO;
//			msgChargeOffline.strOrderId = _orderid;
//			msgChargeOffline.nPcId = 0;
//			msgChargeOffline.nAmount = (int) (dAmount * 100);
//			msgChargeOffline.setAccountID(nAccount);
//			
//			CServerConnectMgr.getConnectMgr().sendMessageToAccount(
//					msgChargeOffline);
			// 成功
			logMsg += "&cperror=200";
			logger.debug("<errcode=1&errmsg=&" + logMsg + ">");
		} else {
			String result="-6";
			response.appendBody(result);
			if (response != null) {
				session.write(response).addListener(IoFutureListener.CLOSE);
			}

			String logMsg = "pid=" + SdkBillingServer.PID_KUWO;
			logMsg += "&orderid=" + _orderid;
			logMsg += "&payway=0";
			logMsg += "&amount=" + (int) (dAmount * 100);
			logMsg += "&account=" + nAccount;
			logMsg += "&serverid=" + serverid;
			logMsg += "&recodedate=" + MyDateFormart.getFormatDate();
			// Sign无效
			logMsg += "&cperror=404";
			logger.debug("<errcode=0&errmsg=Sign无效&" + logMsg + ">");
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
