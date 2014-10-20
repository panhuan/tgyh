package XuanQu.qh360;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLEncoder;
import java.security.KeyManagementException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.cert.X509Certificate;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSession;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.ByteArrayEntity;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.params.HttpConnectionParams;
import org.apache.http.params.HttpParams;
import org.apache.http.util.EntityUtils;
import org.codehaus.jackson.map.ObjectMapper;


/**
 * @author banshuai
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
	 * 执行一个HTTP POST请求，返回请求响应的内容
	 * 
	 * @param url
	 *            请求的URL地址
	 * @param params
	 *            请求的查询参数,可以为null
	 * @return 返回请求响应的内容
	 */
	public static String doPost(String url, String body) {
		StringBuffer stringBuffer = new StringBuffer();
		HttpEntity entity = null;
		BufferedReader in = null;
		HttpResponse response = null;
		try {
			DefaultHttpClient httpclient = new DefaultHttpClient();
			HttpParams params = httpclient.getParams();
			HttpConnectionParams.setConnectionTimeout(params, 20000);
			HttpConnectionParams.setSoTimeout(params, 20000);
			HttpPost httppost = new HttpPost(url);
			httppost.setHeader("Content-Type",
					"application/x-www-form-urlencoded");

			httppost.setEntity(new ByteArrayEntity(body.getBytes("UTF-8")));
			response = httpclient.execute(httppost);
			entity = response.getEntity();
			in = new BufferedReader(new InputStreamReader(entity.getContent()));
			String ln;
			while ((ln = in.readLine()) != null) {
				stringBuffer.append(ln);
				stringBuffer.append("\r\n");
			}
			httpclient.getConnectionManager().shutdown();
		} catch (ClientProtocolException e) {
			e.printStackTrace();
		} catch (IOException e1) {
			e1.printStackTrace();
		} catch (IllegalStateException e2) {
			e2.printStackTrace();
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			if (null != in) {
				try {
					in.close();
					in = null;
				} catch (IOException e3) {
					e3.printStackTrace();
				}
			}
		}
		return stringBuffer.toString();
	}

	/**
	 * doget请求
	 * @param url
	 * @return
	 */
	public static String doGet(String url) {

		String stringBuffer = "";
		HttpEntity entity = null;
		HttpResponse response = null;
		
		try {
			DefaultHttpClient httpclient = new DefaultHttpClient();
			
			HttpParams params = httpclient.getParams();
			HttpConnectionParams.setConnectionTimeout(params, 20000);
			HttpConnectionParams.setSoTimeout(params, 20000);
			
			HttpGet httpGet = new HttpGet(url);

			response = httpclient.execute(httpGet);
			if (response.getStatusLine().getStatusCode() == HttpStatus.SC_OK) {
				entity = response.getEntity();
				stringBuffer = EntityUtils.toString(entity);
			}
			httpclient.getConnectionManager().shutdown();
		} catch (ClientProtocolException e) {
			e.printStackTrace();
		} catch (IOException e1) {
			e1.printStackTrace();
		} catch (IllegalStateException e2) {
			e2.printStackTrace();
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
		}
		return stringBuffer.toString();
	}

	/**
	 * 读取配置信息。
	 * 
	 * @param key
	 *            Key值
	 * @return
	 * @throws Exception
	 */
	public static String getConfig(String key) throws Exception {
		try {
			InputStream in = Util.class
					.getResourceAsStream("/XuanQu/qh360/conf.Properties");
			Properties p = new Properties();
			p.load(in);
			return p.get(key).toString().trim();
		} catch (Exception e) {
			System.out.println("配置文件不存在" + e.toString());
		}
		return "";
	}
	
	/**
	 * http请求
	 * @param url
	 * @param data
	 * @param ignoreSSL
	 * @return
	 * @throws IOException 
	 */
	public static String requestUrl(String url, HashMap<String, String> data, Boolean ignoreSSL)
			throws IOException {

		if (ignoreSSL) {
			_ignoreSSL();
		}

		HttpURLConnection conn;
		try {
			//if GET....
			//URL requestUrl = new URL(url + "?" + httpBuildQuery(data));
			URL requestUrl = new URL(url);
			conn = (HttpURLConnection) requestUrl.openConnection();
		} catch (MalformedURLException e) {
			return e.getMessage();
		}

		conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");

		conn.setDoInput(true);
		conn.setDoOutput(true);

		PrintWriter writer = new PrintWriter(conn.getOutputStream());
		writer.print(httpBuildQuery(data));
		writer.flush();
		writer.close();

		String line;
		BufferedReader bufferedReader;
		StringBuilder sb = new StringBuilder();
		InputStreamReader streamReader = null;
		try {
			streamReader = new InputStreamReader(conn.getInputStream(), "UTF-8");
		} catch (IOException e) {
			/*
			Boolean ret2 = true;
			if (ret2) {
				return e.getMessage();
			}
			*/
			streamReader = new InputStreamReader(conn.getErrorStream(), "UTF-8");
		} finally {
			if (streamReader != null) {
				bufferedReader = new BufferedReader(streamReader);
				sb = new StringBuilder();
				while ((line = bufferedReader.readLine()) != null) {
					sb.append(line);
				}
			}
		}
		return sb.toString();
	}
	//ignoreSSL hostname verifer
	private static HostnameVerifier ignoreHostnameVerifier = new HostnameVerifier() {
		@Override
		public boolean verify(String s, SSLSession sslsession) {
			return true;
		}
	};

	/**
	 * 忽略SSL
	 */
	private static void _ignoreSSL() {
		try {
			// Create a trust manager that does not validate certificate chains
			TrustManager[] trustAllCerts = new TrustManager[]{new X509TrustManager() {
			@Override
			public X509Certificate[] getAcceptedIssuers() {
				return null;
			}

			@Override
			public void checkClientTrusted(X509Certificate[] certs, String authType) {
			}

			@Override
			public void checkServerTrusted(X509Certificate[] certs, String authType) {
			}
		}};

			// Install the all-trusting trust manager

			SSLContext sc = SSLContext.getInstance("TLS");
			sc.init(null, trustAllCerts, new SecureRandom());
			HttpsURLConnection.setDefaultSSLSocketFactory(sc.getSocketFactory());
			HttpsURLConnection.setDefaultHostnameVerifier(ignoreHostnameVerifier);
		} catch (KeyManagementException ex) {
			Logger.getLogger(Util.class.getName()).log(Level.SEVERE, null, ex);
		} catch (NoSuchAlgorithmException ex) {
			Logger.getLogger(Util.class.getName()).log(Level.SEVERE, null, ex);
		}
	}

	/**
	 * 参数编码
	 * @param data
	 * @return 
	 */
	public static String httpBuildQuery(HashMap<String, String> data) {
		String ret = "";
		String k, v;
		Iterator<String> iterator = data.keySet().iterator();
		while (iterator.hasNext()) {
			k = iterator.next();
			v = data.get(k);
			try {
				ret += URLEncoder.encode(k, "utf8") + "=" + URLEncoder.encode(v, "utf8");
			} catch (UnsupportedEncodingException e) {
			}
			ret += "&";
		}
		return ret.substring(0, ret.length() - 1);
	}

	/**
	 * 签名计算
	 * @param params
	 * @param appSecret
	 * @return 
	 */

	public static String getSign(HashMap params, String appSecret) {
		Object[] keys = params.keySet().toArray();
		Arrays.sort(keys);
		String k, v;

		StringBuilder sb = new StringBuilder();
		for (int i = 0; i < keys.length; i++) {
			k = (String) keys[i];
			if (k.equals("sign") || k.equals("sign_return")) {
				continue;
			}
			v = (String) params.get(k);

			if (v.equals("")) {
				continue;
			}

			sb.append(v);
			sb.append("#");
		}
		
		sb.append(appSecret);

		return Util.getMD5(sb.toString());
	}

	public static String md5(String str) {
		StringBuilder sb = new StringBuilder();
		try {
			MessageDigest m = MessageDigest.getInstance("MD5");
			m.update(str.getBytes("UTF8"));
			byte bytes[] = m.digest();

			for (int i = 0; i < bytes.length; i++) {
				if ((bytes[i] & 0xff) < 0x10) {
					sb.append("0");
				}
				sb.append(Long.toString(bytes[i] & 0xff, 16));
			}
		} catch (Exception e) {
		}
		return sb.toString();
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
                md5StrBuff.append("0").append(Integer.toHexString(0xFF & byteArray[i]));  
            else  
                md5StrBuff.append(Integer.toHexString(0xFF & byteArray[i]));  
        }  
  
        return md5StrBuff.toString();  
    }
}
