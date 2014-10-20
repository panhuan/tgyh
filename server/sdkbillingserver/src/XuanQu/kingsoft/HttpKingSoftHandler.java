package XuanQu.kingsoft;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;

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

public class HttpKingSoftHandler extends IoHandlerAdapter{
	private static final Logger logger = LoggerFactory.getLogger("charge");

	@Override
	public void sessionOpened(IoSession session) {
		// set idle time to 60 seconds
		session.getConfig().setIdleTime(IdleStatus.BOTH_IDLE, 60);
	}

	@Override
	public void messageReceived(IoSession session, Object message) {

		HttpRequestMessage msg = (HttpRequestMessage) message;

		// 位支付密钥,金山分配
		String sign = msg.getParameter("sign");
				
		String pfid= msg.getParameter("pfid");	//游戏厂商分配给金山手游联运平台的id编号
		String gid= msg.getParameter("gid");	//金山分配给某款游戏的游戏编号
		String sid= msg.getParameter("sid");	//大区id
		String payway= msg.getParameter("payway");//支付
		String paytime= msg.getParameter("paytime");
		String cpparam= msg.getParameter("cpparam");//游戏内容提供商提供的参数（经过url escape编码最长150字符）
		String time= msg.getParameter("time");//本次请求时间
		String gamemoney= msg.getParameter("gold");
		String money= msg.getParameter("money");
		String orderid= msg.getParameter("oid");
		String uid= msg.getParameter("uid");
		
		String _pfid= "";	//游戏厂商分配给金山手游联运平台的id编号
		String _gid= "";	//金山分配给某款游戏的游戏编号
		String _sid= "";	//大区id
		String _payway= "";//支付
		String _paytime= "";
		String _cpparam= "";//游戏内容提供商提供的参数（经过url escape编码最长150字符）
		String _time= "";//本次请求时间
		String _gamemoney= "";
		String _money= "";
		String _orderid= "";
		String _uid= "";
		
		try {
			_pfid = URLEncoder.encode(pfid, "utf-8");
			_gid = URLEncoder.encode(gid, "utf-8");
			_sid = URLEncoder.encode(sid, "utf-8");
			_payway = URLEncoder.encode(payway, "utf-8");
			_paytime = URLEncoder.encode(paytime, "utf-8");
			_cpparam=URLEncoder.encode(cpparam, "utf-8");
			_time=URLEncoder.encode(time, "utf-8");
			_gamemoney=URLEncoder.encode(gamemoney, "utf-8");
			_money=URLEncoder.encode(money, "utf-8");
			_orderid=URLEncoder.encode(orderid, "utf-8");
			_uid=URLEncoder.encode(uid, "utf-8");
		} catch (UnsupportedEncodingException e1) {
			e1.printStackTrace();
		}
		
		String str ="cpparam="+ _cpparam;
		str +="&gid=" + _gid;
		str +="&gold=" + _gamemoney;
		str +="&money=" + _money;
		str +="&oid="+ _orderid;
		str +="&paytime="+_paytime;
		str +="&payway="+ _payway;
		str +="&pfid=" + _pfid;
		str +="&sid=" + _sid;
		str +="&time=" + _time;
		str +="&uid=" + _uid;
		
		//提供给金山的充值签名验证key
		String key="lovedance_kingsoft";
		String sig = Util.getMD5(str+key);

		HttpResponseMessage response = new HttpResponseMessage();
		response.setResponseCode(HttpResponseMessage.HTTP_STATUS_SUCCESS);

		String _result = "";

		String paymentString[] = cpparam.split("_");

		String nAccount = paymentString[0];
		String serverid = paymentString[1];
		
		Double dAmount = new Double(_money).doubleValue();
//		if (true) {
		if (sig.equals(sign)) {

			String logMsg = "pid=" + SdkBillingServer.PID_KINGSOFT;
			logMsg += "&orderid=" + _orderid;
			logMsg += "&payway=0";
			logMsg += "&amount=" + (int) (dAmount * 1);
			logMsg += "&account=" + nAccount;
			logMsg += "&serverid=" + serverid;
			logMsg += "&recodedate=" + MyDateFormart.getFormatDate();

			_result = HttpSendPartBillServer
					.sendBillServerByServerId(nAccount, (int)(dAmount * 1), orderid,
							"0", SdkBillingServer.PID_KINGSOFT, "", serverid);
			
			if (response != null && (_result != null || !"".equals(_result))) {
				String result="{";
				result+="\"code\""+":"+"1,";
				result+="\"msg\""+":\"\",";
				result+="\"data\""+":{";
				result+="\"oid\""+":"+orderid;
				result+="}}";
				response.appendBody(result);
				session.write(response).addListener(IoFutureListener.CLOSE);
			} else {
				String result="{";
				result+="\"code\""+":"+"-1,";
				result+="\"msg\""+":\"\",";
				result+="\"data\""+":{";
				result+="\"oid\""+":"+orderid;
				result+="}}";
				response.appendBody(result);
				session.write(response).addListener(IoFutureListener.CLOSE);
			}
			// 成功
			logMsg += "&cperror=200";
			logger.debug("<errcode=1&errmsg=&" + logMsg + ">");
		} else {
			if (response != null) {
				session.write(response).addListener(IoFutureListener.CLOSE);
			}

			String logMsg = "pid=" + SdkBillingServer.PID_KINGSOFT;
			logMsg += "&orderid=" + _orderid;
			logMsg += "&payway=0";
			logMsg += "&amount=" + (int) (dAmount * 1);
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
