package XuanQu.qh360.util;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class CalPrivateKey {

	public static void main(String[] args) {
		String appKey = "22c0ac6781873b4a21e0d2d9a20feb91";
		String appSecret = "b564e576334eb20ebe6fdc015257c777";
		String privateKey = getHash(appSecret + "#" + appKey);
		System.out.println(privateKey);
	}

	public static String getHash(String uri) {
		MessageDigest mDigest;
		try {
			mDigest = MessageDigest.getInstance("MD5");
			mDigest.update(uri.getBytes());
			byte d[] = mDigest.digest();
			return toHexString(d);
		} catch (NoSuchAlgorithmException e) {
			e.printStackTrace();
		}
		return uri;
	}

	private static final char HEX_DIGITS[] = { '0', '1', '2', '3', '4', '5',
			'6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' };

	public static String toHexString(byte[] b) { // String to byte
		StringBuilder sb = new StringBuilder(b.length * 2);
		for (int i = 0; i < b.length; i++) {
			sb.append(HEX_DIGITS[(b[i] & 0xf0) >>> 4]);
			sb.append(HEX_DIGITS[b[i] & 0x0f]);
		}
		return sb.toString();
	}
}
