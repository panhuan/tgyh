package XuanQu.multipleServer;

import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.text.SimpleDateFormat;
import java.util.List;

import org.codehaus.jackson.map.ObjectMapper;

/**
 * @author zhanghuaming
 * @date 2014年6月8日
 */

public class Util {

	private static ObjectMapper objectMapper = new ObjectMapper();
	static {
		objectMapper.setDateFormat(new SimpleDateFormat("yyyy-MM-dd"));
	}

	/**
	 * 使用对象进行json反序列化。
	 * 
	 * @param json
	 *            json串
	 * @param pojoClass
	 *            类类型
	 * @return
	 * @throws Exception
	 */
	public static Object decodeJson(String json, Class pojoClass)
			throws Exception {
		try {
			return objectMapper.readValue(json, pojoClass);
		} catch (Exception e) {
			throw e;
		}
	}

	/**
	 * 将对象序列化。
	 * 
	 * @param o
	 *            实体对象
	 * @return 序列化后json
	 * @throws Exception
	 */
	public static String encodeJson(Object o) throws Exception {
		try {
			return objectMapper.writeValueAsString(o);
		} catch (Exception e) {
			throw e;
		}
	}

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
