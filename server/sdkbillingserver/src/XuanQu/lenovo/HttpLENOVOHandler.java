package XuanQu.lenovo;

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
public class HttpLENOVOHandler extends IoHandlerAdapter {
	private static final Logger logger = LoggerFactory.getLogger("charge");

	@Override
	public void sessionOpened(IoSession session) {
		// set idle time to 60 seconds
		session.getConfig().setIdleTime(IdleStatus.BOTH_IDLE, 60);
	}

	// 收到的消息处理
	@Override
	public void messageReceived(IoSession session, Object message) {
		// 支付接口预留ttdt
		HttpRequestMessage msg = (HttpRequestMessage) message;

		String tran = msg.getParameter("transdata");
		JSONTokener jsonTokener = new JSONTokener(tran);
		JSONObject jsonObj = (JSONObject) jsonTokener.nextValue();

		String exorderno = jsonObj.getString("exorderno");

		String transid = jsonObj.getString("transid");
		String appid = jsonObj.getString("appid");
		String waresid = jsonObj.getString("waresid");
		String feetype = jsonObj.getString("feetype");
		String money = jsonObj.getString("money");
		String count = jsonObj.getString("count");
		String result = jsonObj.getString("result");
		String transtype = jsonObj.getString("transtype");
		String transtime = jsonObj.getString("transtime");
		String cpprivate = jsonObj.getString("cpprivate");
		String paytype = jsonObj.getString("paytype");
		//
		String sign = msg.getParameter("sign");

		// 提供给联想的充值签名验证key
		String key = "QjI5RDM0QzBDOTBCRDVCNTM5MzY5RjZGRkQzQTE0NTYyRTg1NjI5Rk1UWXpNVEU1TWpBek16WTROVFUwT1RRMk16TXJNakF3TnprNU9UYzNPVGt5TnpZM01ETTNNVGt4TWpNeE56VTRPRFkzTmpFNE5UazJNVGd6";

		boolean sig = CpTransSyncSignValid.validSign(tran, sign, key);

		HttpResponseMessage response = new HttpResponseMessage();
		response.setResponseCode(HttpResponseMessage.HTTP_STATUS_SUCCESS);

		String _result = "";
		
		String paymentString[] = cpprivate.split("_");
		String nAccount = paymentString[0];
		String serverid = paymentString[1];

		Double dAmount = new Double(money).doubleValue();

		if (sig) {
			String logMsg = "pid=" + SdkBillingServer.PID_LENOVO;
			logMsg += "&orderid=" + exorderno;
			logMsg += "&payway=" + paytype;
			logMsg += "&amount=" + (int) (dAmount * 1);
			logMsg += "&account=" + nAccount;
			logMsg += "&serverid=" + serverid;
			logMsg += "&recodedate=" + MyDateFormart.getFormatDate();
			
			if ("0".equals(result)) {
				_result = HttpSendPartBillServer
						.sendBillServerByServerId(nAccount, (int) (dAmount * 1), exorderno,
								paytype, SdkBillingServer.PID_LENOVO, "", serverid);
			}
			
			if (response != null && "success".equals(_result)) {
				response.appendBody("SUCCESS");
				session.write(response).addListener(IoFutureListener.CLOSE);
			} else {
				response.appendBody("FAILURE");
				session.write(response).addListener(IoFutureListener.CLOSE);
			}
			// 成功

			logMsg += "&cperror=200";
			logger.debug("<errcode=1&errmsg=&" + logMsg + ">");
		} else {

			response.appendBody("FAILURE");
			if (response != null) {
				session.write(response).addListener(IoFutureListener.CLOSE);
			}

			String logMsg = "pid=" + SdkBillingServer.PID_LENOVO;
			logMsg += "&orderid=" + exorderno;
			logMsg += "&payway=" + paytype;
			logMsg += "&amount=" + (int) (dAmount * 1);
			logMsg += "&account=" + count;
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
