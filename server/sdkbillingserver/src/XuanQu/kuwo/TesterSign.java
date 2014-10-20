package XuanQu.kuwo;

import java.io.UnsupportedEncodingException;

/**
 * @author banshuai
 *
 */
public class TesterSign {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		String appId="7095";
		String cpOrderId = "7095-2702150-201331915482648156";
		String cpUserInfo="97";
		String orderId="21136367930912078329";
		String orderStatus="TRADE_SUCCESS";
		String payFee="100";
		String payTime="2013-03-19+15%3A48%3A33";
		String productCode="01";
		String prodectCount="100";
		String productName="M%E5%B8%81";
		//平台返回的签名
		String signature="c5dba98f902d80ddcb7105ec311688899f39afc1";
		String uid="2702150";
		
		String appKey = "cbb2129a-3fa0-48c1-5be6-513ee14b776a";
		
		try {
			productName = java.net.URLDecoder.decode (productName,"utf-8");
			payTime = java.net.URLDecoder.decode (payTime,"utf-8");
			} catch (UnsupportedEncodingException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

//		System.out.println("productName=" + productName);
//		System.out.println("payTime=" + payTime);
		
		String signStr = "appId=" + appId
				+ "&cpOrderId=" + cpOrderId
				+ "&cpUserInfo=" + cpUserInfo + "&orderId="
				+ orderId + "&orderStatus="
				+ orderStatus + "&payFee="
				+ payFee + "&payTime="
				+ payTime + "&productCode="
				+ productCode + "&productCount="
				+ prodectCount + "&productName="
				+ productName + "&uid="
				+ uid;
		try {
			String _signStr = HmacSHA1Encryption.HmacSHA1Encrypt(signStr, appKey);
//			System.out.println(_signStr);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	 public static String changeCharset(String str, String newCharset)
			   throws UnsupportedEncodingException {
			  if (str != null) {
			   //用默认字符编码解码字符串。
			   byte[] bs = str.getBytes();
			   //用新的字符编码生成字符串
			   return new String(bs, newCharset);
			  }
			  return null;
			 }

}
