package XuanQu.multipleServer;

import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.List;

/**
 * @author zhanghuaming
 * @date 2014年6月8日
 */

public class Util {

	/**
	 * MD5 加密
	 */
	public static String getMD5(String str) {
		MessageDigest messageDigest = null;

		try {
			messageDigest = MessageDigest.getInstance("MD5");

			messageDigest.reset();

			messageDigest.update(str.getBytes("UTF-8"));
		} catch (NoSuchAlgorithmException e) {
			System.out.println("NoSuchAlgorithmException caught!");
			System.exit(-1);
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}

		byte[] byteArray = messageDigest.digest();

		StringBuffer md5StrBuff = new StringBuffer();

		for (int i = 0; i < byteArray.length; i++) {
			if (Integer.toHexString(0xFF & byteArray[i]).length() == 1)
				md5StrBuff.append("0").append(
						Integer.toHexString(0xFF & byteArray[i]));
			else
				md5StrBuff.append(Integer.toHexString(0xFF & byteArray[i]));
		}

		return md5StrBuff.toString();
	}

	public static String getServerAddressByMutipleServers(
			List<ServerInfo> serverInfos, String serverId) {
		
		String address = null;
		for (ServerInfo serverInfo : serverInfos) {
			if (serverInfo.getServerid().trim().equals(serverId.trim())) {
				address = serverInfo.getIp() + ":" + serverInfo.getPort();
			}
		}
		
		return address;
	}
}
