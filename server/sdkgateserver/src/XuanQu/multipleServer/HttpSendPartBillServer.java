package XuanQu.multipleServer;


public class HttpSendPartBillServer {
	
	public static String sendBillServerByServerId(String account, int amount,
			String orderid, String payway, short pid, String puid,
			String serverid) {
		
		String str = "account=" + account + "amount=" + amount + "&orderid="
				+ orderid + "&payway=" + payway + "&pid=" + pid + "&puid="
				+ puid;
		
//		String sign = Util.getMD5(str).toLowerCase();		
//		String url = "";
//		url += "account=" + account;
//		url += "&amount=" + amount;
//		url += "&orderid=" + orderid;
//		url += "&payway=" + payway;
//		url += "&pid=" + pid;
//		url += "&puid=" + puid;
//		url += "&sign=" + sign;
//		String resultResponse = HttpUtil.doGet(url);
		
		String resultResponse = TcpUtil.send(serverid, str);

		return resultResponse;
	}
}
