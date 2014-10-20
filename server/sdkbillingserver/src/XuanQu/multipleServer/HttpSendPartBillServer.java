package XuanQu.multipleServer;


public class HttpSendPartBillServer {
	
	public static String sendBillServerByServerId(String account, int amount,
			String orderid, String payway, short pid, String puid,
			String serverid) {
		
		StringBuilder msg = new StringBuilder();
		msg.append("pay");
		msg.append(",");
		msg.append(account);
		msg.append(",");
		msg.append(amount);
		msg.append(",");
		msg.append(orderid);
		msg.append(",");
		msg.append(payway);
		msg.append(",");
		msg.append(pid);
		msg.append(",");
		msg.append(puid);
		
		return TcpUtil.send(serverid, msg.toString());
	}
}
