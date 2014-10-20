package XuanQu.sina;

import java.security.KeyFactory;
import java.security.PrivateKey;
import java.security.Signature;
import java.security.spec.PKCS8EncodedKeySpec;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import org.apache.commons.beanutils.BeanUtils;
import org.apache.commons.codec.binary.Base64;

public class SignUtil {
	public static String getMD5(byte[] source) {
		String s = null;
		char hexDigits[] = { // 用来将字节A转换成 16 进制表示的字符
		'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' };
		try {
			java.security.MessageDigest md = java.security.MessageDigest.getInstance("MD5");
			md.update(source);
			byte tmp[] = md.digest(); // MD5 的计算结果是一个 128 位的长整数，
			// 用字节表示就是 16 个字节
			char str[] = new char[16 * 2]; // 每个字节用 16 进制表示的话，使用两个字符，
			// 所以表示成 16 进制需要 32 个字符
			int k = 0; // 表示转换结果中对应的字符位置
			for (int i = 0; i < 16; i++) { // 从第一个字节开始，对 MD5 的每一个字节
				// 转换成 16 进制字符的转换
				byte byte0 = tmp[i]; // 取第 i 个字节
				str[k++] = hexDigits[byte0 >>> 4 & 0xf]; // 取字节中高 4 位的数字转换,
				// >>>
				// 为逻辑右移，将符号位一起右移
				str[k++] = hexDigits[byte0 & 0xf]; // 取字节中低 4 位的数字转换
			}
			s = new String(str); // 换后的结果转换为字符串

		} catch (Exception e) {
			e.printStackTrace();
		}
		return s;
	}

	public static String sign(String alg, String content, PrivateKey privateKey) {
		try {
			Signature signalg = Signature.getInstance(alg);
			signalg.initSign(privateKey);
			signalg.update(content.getBytes());
			byte[] signature = signalg.sign();
			return Base64.encodeBase64String(signature);
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}

	public static String getSign(String key, String keyType, String signContent) {
		String result = null;
		if ("MD5".equals(keyType)) {
			signContent += "&key=" + key;
			result = getMD5(signContent.getBytes());
		} else if ("SHA1withRSA".equals(keyType)) {
			key = key.replace(' ', '+');
			try {
				PKCS8EncodedKeySpec spec = new PKCS8EncodedKeySpec(Base64.decodeBase64(key));
				KeyFactory fact = KeyFactory.getInstance("RSA");
				String content = sign(keyType, signContent, fact.generatePrivate(spec));
				result = content;

			} catch (Exception e) {
				e.printStackTrace();
			}
		} 
		return result;
	}

	public static void main(String[] args) {
		String key = "MIICeAIBADANBgkqhkiG9w0BAQEFAASCAmIwggJeAgEAAoGBAMCvwa2sTQwLbEgRXZvcBFeyscCYUBF6+bGbVVIfp1c0bcf4PLUnz9P+ePpwraZKOqCRNtbE2EXjJnu9gehBxkBOWIYCuaeD7AY7hjs/PQyLcbB6/zuskOolPH45g1aTVVogyeN8eCd32I0pOHsdEJ820s10b2MtpTUPcG4yvdHdAgMBAAECgYB62NM7Xcm1byb2/5NVxj1CiFwJdVI/As9k66rG9AVldLi1ME/ME3jOKMSKrwIXLeYY7twuq0tTq1GivJyxLhYtVcbK4FgqusYzZr22Aw/9kbzDaloqYwOM46i4QNOydaa/1fgEHkHbTe7a92bQMzIncGycolhcItAMvHYuXgJZxQJBAP3vvXQ5QDDhQOnYvd1nDhVMF3qSN+JGfL4LK4o5H1e7jNkV/SGE+wQpK6FK4xhQnTjSa4SB1oIL8ZSd6EXk0JsCQQDCQJloy+FfWfdHMaLZecrpV7oaxJaNfnOPMQFC1otb6zs/T07V5G3L574uJu6GLCAMFK48ViHzdbr5v2I/QyLnAkEAk/qUTdlbBeEOQffTVOVMOK7586ynsk3fPaQmwErfb/HUd2Ev/MuQt/ECAuEwC6hWpplAnJxJE8nAAxouFCTuRwJBAJbY7Yj5EpomViW+QPVbZBySmJ4i3bshYIHpD06lJvGJmafPYawuSKlY3FIgv4gIChb3lFqclJ7oZPt/CL+R1i8CQQCLXUbjHiWhuAbqKLxCTKvjnwWmwmB+4t5OHKVuFNRmjNffhvwRvPtle2cfOY/77voZgwC4fuBsKxHJumFI5DI3";
		String keyType = "SHA1withRSA";
		String str = "inputCharset=1&bgUrl=https://func-mas-order.weibopay.com/acquire-order-channel/mock/collectNotifyResult.htm&version=v2.3&language=1&signType=4&merchantAcctId=200100200120000374899501101&orderId=20030270&orderAmount=1&orderTime=20121017165834&productName=李宁运动鞋&productNum=1&productId=0012&productDesc=黑色运动鞋一双，附带赠品（护腕）&payType=10&bankId=SDTBNK&redoFlag=0&pid=200003748995";
		System.out.println(getSign(key,keyType,str));
	}

}
