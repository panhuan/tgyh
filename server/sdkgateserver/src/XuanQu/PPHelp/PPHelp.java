package XuanQu.PPHelp;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.InetAddress;
import java.net.Socket;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.CharBuffer;
import java.nio.charset.Charset;

import XuanQu.PPHelp.model.RecvPSData;

public class PPHelp {

	public void Init() throws Exception {
	}

	private byte[] getBytes(char[] chars) {
		Charset cs = Charset.forName("UTF-8");
		CharBuffer cb = CharBuffer.allocate(chars.length);
		cb.put(chars);
		cb.flip();
		ByteBuffer bb = cs.encode(cb);

		return bb.array();
	}

	/**
	 * 检查用户登陆sessionId是否有效
	 * 
	 * @param aPlayer
	 * @param aRequest
	 */
//	public void checkSessionId(Player aPlayer, XQClientAccount_Login aRequest) {
//		if (aRequest != null && aPlayer != null) {
//			try {
//
//				XQClientAccount_Login al2 = (XQClientAccount_Login) aRequest;
//
//				aPlayer.setPID(al2.getPID());
//				aPlayer.setPUID(al2.getPUID());
//				aPlayer.setToken(al2.getToken());
//				aPlayer.setName(al2.getName());
//
//				XQServerAccountLoginMsg sal2 = al2.ToXQServerAccountLoginMsg();
//				// 支持多个gate服务，设置sessionId
//				sal2.setGateSession(aPlayer.getGateSessionID());
//				aPlayer.PlayerSendMessgeToServer(sal2, sal2.getType());
//
//			} catch (Exception e) {
//				e.printStackTrace();
//			}
//
//		}
//	}

	/**
	 * PP µ«¬º—È÷§
	 * 
	 * @param uid
	 * @param session
	 * @return
	 */
	public static RecvPSData sendToPPServer(byte[] array) {

		byte [] b = array;
		int length = b.length + 8;
		Socket client = null;
		try {
			InetAddress inStr = InetAddress.getByName("mobileup.25pp.com");	
			
			client = new Socket(inStr, 8080);
			client.setReuseAddress(false);
			
			InputStream in = client.getInputStream();
			OutputStream out = client.getOutputStream();
			
			ByteBuffer inbf = ByteBuffer.allocate(length);
			inbf.order(ByteOrder.LITTLE_ENDIAN);
			inbf.putInt(length);
			inbf.putInt(0xAA000022);
			inbf.put(b);
			inbf.rewind();
			out.write(inbf.array());
			out.flush();
			
			byte[] read = readStream(in);
			if(read.length > RecvPSData.MiniObjectSize)
			{
				RecvPSData recvPSData = new RecvPSData();
				ByteBuffer otbf = ByteBuffer.wrap(read);
				otbf.order(ByteOrder.LITTLE_ENDIAN);
				recvPSData.setLen(otbf.getInt());
				recvPSData.setCommand(otbf.getInt());
				recvPSData.setStatus(otbf.getInt());
				byte busername[] = new byte[recvPSData.getLen()-(3*4+8)-1];	//取 username 字节长度为 RecvPSData.getLen()-(3*4+8) 字符串长度为RecvPSData.getLen()-(3*4+8)-1
				otbf.get(busername, 0, recvPSData.getLen()-(3*4+8)-1);
				String username = new String(busername, "UTF-8");
				otbf.get(); //跳过username C++ 结束标志'\0'
				recvPSData.setUserid(otbf.getLong());
				recvPSData.setUsername(username);
				System.out.println("Recv from PP Server data length: " + recvPSData.getLen());
				System.out.println("Recv from PP Server data command: " + recvPSData.getCommand());
				System.out.println("Recv from PP Server data status: " + recvPSData.getStatus());
				System.out.println("Recv from PP Server data username: " + recvPSData.getUsername());
				System.out.println("Recv from PP Server data userid: " + recvPSData.getUserid());
				return recvPSData;
			}
			
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {
				client.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		
		return null;
	}

	/**
	 * 读取流
	 * 
	 * @param inStream
	 * @return 字节数组
	 * @throws Exception
	 */
	public static byte[] readStream(InputStream inStream) throws Exception {
		ByteArrayOutputStream outSteam = new ByteArrayOutputStream();
		byte[] buffer = new byte[1024];
		int len = -1;
		/*while */if ((len = inStream.read(buffer)) != -1) {
			outSteam.write(buffer, 0, len);
		}
		outSteam.close();
		return outSteam.toByteArray();
	}

}
