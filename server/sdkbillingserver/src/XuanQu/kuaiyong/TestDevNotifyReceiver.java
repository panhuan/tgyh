package XuanQu.kuaiyong;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.Servlet;
import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.log4j.Logger;

import sun.misc.BASE64Decoder;


/**
 * Servlet implementation class MappServlet
 */

public class TestDevNotifyReceiver extends HttpServlet implements Servlet {
	private static final long serialVersionUID = 1L;
	ServletConfig config;
	// ClientHandler clientHandler;
	private Logger logger = Logger.getLogger(TestDevNotifyReceiver.class);
	
	private String pubKey = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC+WNnrVVHQEcE3VwiuOPdAMZ5NGgs4Dikn6vd+XTURtAwn/86jd7En86F4s61pq7zjABNsVka8lpeq0Dq9XbXOQAPHJBt4PyEKA9EJ9XMeGF63UeJYPmN5VgrGtLJdPoFLY5AdTiNf3v6+CHyIoDs0NWsw3OSbostMbgwm7Z5A+wIDAQAB";

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public TestDevNotifyReceiver() {
		super();
	}

	/**
	 * @see Servlet#init(ServletConfig)
	 */
	public void init(ServletConfig config) throws ServletException {
		System.out.println("TestDevNotifyReceiver init!!!!!!!!!!!!!!!!");

		super.init(config);
		this.config = config;

	}

	/**
	 * @see Servlet#destroy()
	 */
	public void destroy() {
		System.out.println("TestDevNotifyReceiver destroy!!!!!!!!!!!!!!!!");
	}

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

		String notify_data="";
		String orderid="";
		String dealseq="";
		String sign="";
		String uid;
		String subject;
		String v;
        boolean result = false;
        try {
        	request.setCharacterEncoding("UTF-8");
            Map<String, String> transformedMap = new HashMap<String,String>();
            //获得通知签名
            notify_data = request.getParameter("notify_data");
            transformedMap.put("notify_data", notify_data);
            orderid = request.getParameter("orderid");
            transformedMap.put("orderid", orderid);
            sign = request.getParameter("sign");
            transformedMap.put("sign", sign);
            dealseq = request.getParameter("dealseq");
            transformedMap.put("dealseq", dealseq);
            uid = request.getParameter("uid");
            transformedMap.put("uid", uid);
            subject = request.getParameter("subject");
            transformedMap.put("subject", subject);
            v = request.getParameter("v");
            transformedMap.put("v", v);
            
            //rsa签名验签
            String verify = getVerifyData(transformedMap);
            logger.info("verfiy data:" + verify);
            logger.info("sign is:" + sign);
            if(!RSASignature.doCheck(verify, sign, pubKey, "utf-8")){
            	logger.info("RSA验签失败，数据不可信" + verify);
            }else{
            	logger.info("RSA验签成功，数据可信:" + verify);
	            RSAEncrypt rsaEncrypt= new RSAEncrypt();
	            BASE64Decoder base64Decoder = new BASE64Decoder();
	            
	            //加载公钥   
	            try {
	                rsaEncrypt.loadPublicKey(pubKey); 
	                logger.info("加载公钥成功");  
	            } catch (Exception e) {  
	            	logger.error("load rsa public key failed, 加载公钥失败");
	            	logger.error(e,e);  
	            	
	            }  
	            
	        	
	          //公钥解密通告加密数据
	            byte[] dcDataStr = base64Decoder.decodeBuffer(notify_data);
	            byte[] plainData = rsaEncrypt.decrypt(rsaEncrypt.getPublicKey(), dcDataStr);  
	            logger.info("KuaiYong Notify Data:" + new String(plainData, "UTF-8"));
	            
	            //TODO:开发商在这里比对收到的订单和本地订单，通过dealseq，然后做相应处理
	            
	            result = true;
	            
	            //返回成功信息
	            response.getWriter().write("success");
            }
                
        } catch(Exception e) {
            logger.info("KuaiYong notify Exception, url - " + request.getRequestURI() + "?" + notify_data);
            logger.error(e, e);
        }
        
        //记录日志
        if (result) {
            logger.info("KuaiYong notify succ, url - " + request.getRequestURI() + "?" + notify_data);
        } else {
        	response.getWriter().write("failed");
            logger.info("KuaiYong notify failed, url - " + request.getRequestURI() + "?" +notify_data);
        }
		
		closeSession(request, response);
	}


	public void sendResponse(String resp, HttpServletResponse response) {
		try {
			response.setContentType("text/xml");
			response.setCharacterEncoding("UTF-8");
			int len = resp.getBytes("UTF-8").length;
			response.setContentLength(len);
			
			PrintWriter out = response.getWriter();
			out.write(resp);
			out.close();
			
		} catch (Exception ex) {
			logger.error(ex, ex);
		}
	}
	
	/**
	 * 设置关闭参数
	 * 
	 * @param request
	 * @param response
	 */
	private void closeSession(HttpServletRequest request, HttpServletResponse response) {
		try {

			response.setHeader("Connection", "close");
			// 不要让浏览器开辟缓存
			response.setHeader("Cache-Control", "no-cache");
			response.setHeader("Cache-Control", "no-store");
			// 程序立即过期
			response.setDateHeader("Expires", 0);

			// 不要让浏览其缓存程序
			response.setHeader("Pragma", "no-cache");

			try {
				HttpSession session = request.getSession();
				if (session != null) {
					session.invalidate();
				}
			} catch (Exception ex) {
				// logger.error(ex, ex);
			}
		} catch (Exception ex) {
			System.out.println(ex);
		}

	}
	
    /**
     * 获得验签名的数据
     * @param map
     * @return
     */
    private String getVerifyData(Map<String,String> map) {
        String signData = getSignData(map);
        return signData;
    }
	
	/**
	 * 获得MAP中的参数串；
	 * 
	 * @param params
	 * @return
	 */
	public static String getSignData(Map<String, String> params) {
		StringBuffer content = new StringBuffer();
		List<String> keys = new ArrayList<String>(params.keySet());
		Collections.sort(keys);

		for (int i = 0; i < keys.size(); i++) {
			String key = (String) keys.get(i);

			if ("sign".equals(key)) {
				continue;
			}
			String value = (String) params.get(key);
			if (value != null) {
				content.append((i == 0 ? "" : "&") + key + "=" + value);
			} else {
				content.append((i == 0 ? "" : "&") + key + "=");
			}
		}
		return content.toString();
	}
	
    
}
