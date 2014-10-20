package XuanQu.multipleServer;

import java.io.IOException;
import java.io.OutputStream;
import java.net.Socket;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

/**
 * @author zhanghuaming
 * @date 2014年6月8日
 */

public class TcpUtil {
	protected static Map<String, Socket> mTcpMap = new HashMap<String, Socket>();

	public static void Initial(List<ServerInfo> serverList) {
		
		for(ServerInfo s : serverList ) {
			connect(s.getServerid(), s.getIp(), s.getPort());
		}
		
	}
	public static Boolean connect(String id, String ip, int port){
        try { 
        	if (!mTcpMap.containsKey(id)){
        		
	        	Socket socket = new Socket(ip, port);
				System.out.println("TcpUtil connect: state" + socket.isConnected());
	        	if (socket.isConnected()){
	        		mTcpMap.put(id, socket);
					System.out.println("TcpUtil connect: id:" + id + ", ip:" + ip + ", port:" + port);
	        	}
        	}
        } catch (Exception e) {  
            // TODO Auto-generated catch block  
            e.printStackTrace();  
        }
        
		return true;
	}
	
	public static Boolean disConnect(String id){
		Socket socket = mTcpMap.get(id);
		if (socket == null){
			System.out.println("TcpUtil disConnect: server " + id + " is null!");
			return false;
		}

		try {
			socket.close();
			System.out.println("TcpUtil disConnect: server" + id); 
			
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return true;
	}
	
	public static String send(String id, String msg){
		Socket socket = mTcpMap.get(id);
		if ((socket == null) || (!socket.isConnected())) {
			System.out.println("TcpUtil disConnect: server " + id + " is null!");
			return null;
		}
		
		OutputStream outStream = null;
		try {
			outStream = socket.getOutputStream();
		} catch (IOException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}

		try {
			msg += "\n";
			outStream.write(msg.getBytes());
			System.out.println("TcpUtil send: " + msg);
			
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		return "ok";
	}

	
}
