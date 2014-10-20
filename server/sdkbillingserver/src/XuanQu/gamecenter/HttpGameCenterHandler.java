package XuanQu.gamecenter;

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
public class HttpGameCenterHandler extends IoHandlerAdapter {
	private static final Logger logger = LoggerFactory.getLogger("charge_ios");
	private static final Logger logger_Flag = LoggerFactory.getLogger("charge_ios_Flag");

	@Override
	public void sessionOpened(IoSession session) {
		// set idle time to 60 seconds
		session.getConfig().setIdleTime(IdleStatus.BOTH_IDLE, 60);
	}

	// 收到的消息处理
	@Override
	public void messageReceived(IoSession session, Object message) {
		// 支付接口预留
		HttpRequestMessage request = (HttpRequestMessage) message;

		// String strReturn = IOS.payCallback(msg, logger);
		HttpResponseMessage response = new HttpResponseMessage();
		response.setResponseCode(HttpResponseMessage.HTTP_STATUS_SUCCESS);

		// 内付费正式server地址
		String ServerUrl = "";
		// 内付费测试server地址
		String TestServerUrl = "";

		try {
			ServerUrl = Util.getConfig("ServerUrl");
			TestServerUrl = Util.getConfig("TestServerUrl");
		} catch (Exception e1) {
			e1.printStackTrace();
		}

		String _result = "";
		String resultMessage = "";
		try {
			String receipt_data = request.getParameter("receipt_data");
			String _receipt_data=URLDecoder.decode(receipt_data, "utf-8");
			String receipt_Acount = request.getParameter("Acount");
			String environment=request.getParameter("environment");
			String version_type = request.getParameter("version_type");
			String money = request.getParameter("money");

			//收到消息马上记录log
			logger_Flag.debug("<receipt_Acount=" + receipt_Acount + "&money=" + money + "&datetime=" + MyDateFormart.getToDate() + "&environment=" + environment + "&version_type=" + version_type + "&receipt_data=&" + receipt_data + ">");
			
			String body = "{\"receipt-data\":\"" + _receipt_data + "\"}";
			String confirmUrl="";
			if (receipt_data != null) {
				if(environment.equals("Sandbox")){
					confirmUrl=TestServerUrl;
				}else{
					confirmUrl=ServerUrl;
				}
				String result = Util.doPost(confirmUrl, body);
				
				//到苹果后台确认完订单后再次记录log
				logger_Flag.debug("<receipt_Acount=" + receipt_Acount + "&datetime=" + MyDateFormart.getToDate() + "&result=" + result + ">");
				JSONTokener jsonParser = new JSONTokener(result);
				// 此时还未读取任何json文本，直接读取就是一个JSONObject对象。
				JSONObject resultJson = (JSONObject) jsonParser.nextValue();
				// 接下来的就是JSON对象的操作了
				ResponseReceived Response = new ResponseReceived(
						resultJson.getString("status"),
						resultJson.getString("receipt"));

				//
				JSONTokener receipt_jsonTokener = new JSONTokener(
						resultJson.getString("receipt"));
				JSONObject receipt_resultJson = (JSONObject) receipt_jsonTokener
						.nextValue();

				String receipt = null;
				
				String paymentString[] = receipt_Acount.split("_");

				String nAccount = paymentString[0];
				String serverid = paymentString[1];
				
				String orderid = receipt_resultJson.getString("transaction_id");
				double dAmount = identifier_pay(receipt_resultJson.getString("product_id"));

				String logMsg = "pid=" + SdkBillingServer.PID_GAMECENTER;
				logMsg += "&orderid=" + orderid;
				logMsg += "&payway="+ "applePay";
				logMsg += "&amount=" + (int) (dAmount * 100);
				logMsg += "&account=" + nAccount;
				logMsg += "&serverid=" + serverid;
				logMsg += "&recodedate=" + MyDateFormart.getFormatDate();

				if (Response.getStatus().equals("0")) {
					receipt = XuanQu.gamecenter.Util.getFromBASE64(Response
							.getReceipt());
					
					_result = HttpSendPartBillServer.sendBillServerByServerId(nAccount,
							(int)(dAmount * 100),
							orderid,
							version_type,
							SdkBillingServer.PID_GAMECENTER,
							"",
							serverid);
					// 成功
					logMsg += "&cperror=200";
					logger.debug("<errcode=1&errmsg=&" + logMsg + ">");
					resultMessage = "{\"ErrorCode\":\"1\",\"ErrorDesc\":\"接收成功\"} ";
				} else {
					Double dAmount1 = dAmount;

					String logMsg1 = "pid=" + SdkBillingServer.PID_GAMECENTER;
					logMsg += "&orderid=" + orderid;
					logMsg += "&payway=0";
					logMsg += "&amount=" + (int) (dAmount1 * 100);
					logMsg += "&account=" + nAccount;
					logMsg += "&serverid=" + serverid;
					logMsg += "&recodedate=" + MyDateFormart.getFormatDate();
					// 失败
					logMsg += "&cperror=404";
					logger.debug("<errcode=0&errmsg=Sign无效&" + logMsg1 + ">");
					resultMessage = "{\"ErrorCode\":\"0\",\"ErrorDesc\":\"接收失败\"} ";
				}
			} else {
				// 失败
				String logMsgNull = "pid=" + SdkBillingServer.PID_GAMECENTER;
				logMsgNull += "&orderid=-1";
				logMsgNull += "&payway=-1";
				logMsgNull += "&amount=-1";
				logMsgNull += "&account=-1";
				logMsgNull += "&serverid=";
				logMsgNull += "&recodedate=" + MyDateFormart.getFormatDate();

				logMsgNull += "&cperror=-1";
				logger.debug("<errcode=-1&errmsg=request为空&" + logMsgNull + ">");
				resultMessage = "{\"ErrorCode\":\"0\",\"ErrorDesc\":\"接收失败\"} ";
				// 失败
			}
		} catch (Exception e) {
			// System.out.println("接收支付回调通知的参数失败");
			// 失败
			String logMsgError = "pid=" + SdkBillingServer.PID_GAMECENTER;
			logMsgError += "&orderid=0";
			logMsgError += "&payway=0";
			logMsgError += "&amount=0";
			logMsgError += "&account=0";
			logMsgError += "&serverid=";
			logMsgError += "&recodedate=" + MyDateFormart.getFormatDate();
			logMsgError += "&cperror=0";
			logger.debug("<errcode=0&errmsg=异常&" + logMsgError + ">");
			// 失败
			resultMessage = "{\"ErrorCode\":\"0\",\"ErrorDesc\":\"接收失败\"} ";
		}

		if (response != null && (!_result.equals("") && "success".equals(_result))) {
			response.appendBody(resultMessage);
			session.write(response).addListener(IoFutureListener.CLOSE);
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
	
	public int identifier_pay(String identifier) {
		int pay;
		if (identifier.equalsIgnoreCase("com.ddianle.lovedance.ddl.item1")) {
			pay = 6;
		}else if (identifier.equalsIgnoreCase("com.ddianle.lovedance.ddl.item3")) {
			pay = 18;
		}else if (identifier.equalsIgnoreCase("com.ddianle.lovedance.ddl.item4")) {
			pay = 30;
		}else if (identifier.equalsIgnoreCase("com.ddianle.lovedance.ddl.item5")) {
			pay = 98;
		}else if (identifier.equalsIgnoreCase("com.ddianle.lovedance.ddl.item6")) {
			pay = 298;
		}else if (identifier.equalsIgnoreCase("com.ddianle.lovedance.ddl.item7")) {
			pay = 488;
		}else if (identifier.equalsIgnoreCase("com.ddianle.lovedance.ddl.item8")) {
			pay = 618;
		}else if (identifier.equalsIgnoreCase("com.ddianle.lovedance.lianwufree.item1")) {
			pay = 6;
		}else if (identifier.equalsIgnoreCase("com.ddianle.lovedance.lianwufree.item3")) {
			pay = 18;
		}else if (identifier.equalsIgnoreCase("com.ddianle.lovedance.lianwufree.item4")) {
			pay = 30;
		}else if (identifier.equalsIgnoreCase("com.ddianle.lovedance.lianwufree.item5")) {
			pay = 98;
		}else if (identifier.equalsIgnoreCase("com.ddianle.lovedance.lianwufree.item6")) {
			pay = 298;
		}else if (identifier.equalsIgnoreCase("com.ddianle.lovedance.lianwufree.item7")) {
			pay = 488;
		}else if (identifier.equalsIgnoreCase("com.ddianle.lovedance.lianwufree.item8")) {
			pay = 618;
		}
		else {
			pay = 0;
		}
		return pay;
	}
}
