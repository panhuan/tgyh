package XuanQu.multipleServer;

import java.util.Arrays;

import XuanQu.RWGate.SdkGateServer;


/**
 * @author zhanghuaming
 * @date 2014年6月11日
 */

public class MessageHandle {

	private static long playerLoginSuccessTime = 0L;
	public static long playerBegintime = 0L;
	
	public static void DecodeMsg(String msg) {

        if ((msg == null) || (msg.length() == 0)) {
        	return;
        }
        
        String array[] = msg.split(",");
        if (array.length < 1) {
        	return;
        }
        
        String type = array[0];
        if (type.equals("login")) {
        	String param[] = Arrays.copyOfRange(array, 1, array.length);
        	HandlerLogin(param);
        }
        else {
        	System.out.println ( "MessageHandle:DecodeMsg, unknow msg " + msg);
    		return;
        }
	}
	static void HandlerLogin(final String param[]) {
		playerBegintime = System.currentTimeMillis();
		
		short pId = (short) Integer.parseInt(param[0]);
//		if (pId == SdkGateServer.PID_DOWNJOY) {// downjoy
//			player.setToken(al.getToken());
//			SdkGateServer.getDownjoy().checkSessionId(player, al);
//		} else if (pId == SdkGateServer.PID_UCWEB) {// ucweb
//			player.setToken(al.getToken());
//			SdkGateServer.getUCWeb().sidInfo(player, al);
//		} else if (pId == SdkGateServer.PID_DDIANLE) {// ddianle
//			player.setPID(pId);
//			XQServerAccountLoginMsg sal = al.ToXQServerAccountLoginMsg();
//			sal.setGateSession(player.getGateSessionID());
//			player.PlayerSendMessgeToServer(sal, sal.getType());
//		} else if (pId == SdkGateServer.PID_WL91) {// 91
//			player.setToken(al.getToken());
//			SdkGateServer.getWl91().checkSessionId(player, al);
//		} else if (pId == SdkGateServer.PID_MIUI) {// miui
//			player.setToken(al.getToken());
//			SdkGateServer.getMiui().checkSessionId(player, al);
//		}  
		if (pId == SdkGateServer.PID_QH360) {// 360
        	String param2[] = Arrays.copyOfRange(param, 1, param.length);
			SdkGateServer.getQh360().login(param2);
//		} else if (pId == SdkGateServer.PID_BAIDU) {// baidu
//			player.setToken(al.getToken());
//			SdkGateServer.getBaidu().checkSessionId(player, al);
//		} else if (pId == SdkGateServer.PID_KUWO) {// 酷我
//			player.setToken(al.getToken());
//			SdkGateServer.getKuwo().checkSessionId(player, al);
//		} else if (pId == SdkGateServer.PID_4399) {// 4399
//			player.setToken(al.getToken());
//			SdkGateServer.getI4399().checkSessionId(player, al);
//		} else if (pId == SdkGateServer.PID_KINGSOFT) {// kingsoft
//			player.setToken(al.getToken());
//			SdkGateServer.getKingSoft().checkSessionId(player, al);
//		} else if (pId == SdkGateServer.PID_TTDT) {// TTDT
//			player.setToken(al.getToken());
//			SdkGateServer.getTtdt().checkSessionId(player, al);
//		} else if (pId == SdkGateServer.PID_PPHELP) {// PPhelp
//			player.setToken(al.getToken());
//			SdkGateServer.getPPHelp().checkSessionId(player, al);
//		} else if (pId == SdkGateServer.PID_GameCenter) {
//			player.setToken(al.getToken());
//			SdkGateServer.getGameCenter().checkSessionId(player, al);
//		} else if (pId == SdkGateServer.PID_DDL) {
//			player.setToken(al.getToken());
//			SdkGateServer.getDdl().checkSessionId(player, al);
//		} else if (pId == SdkGateServer.PID_OPPO) {
//			player.setToken(al.getToken());
//			SdkGateServer.getOppo().checkSessionId(player, al);
//		} else if (pId == SdkGateServer.PID_WANDOUJIA) {
//			player.setToken(al.getToken());
//			SdkGateServer.getWdj().checkSessionId(player, al);
//		} else if (pId == SdkGateServer.PID_KUAIYONG) {
//			player.setToken(al.getToken());
//			SdkGateServer.getKy().checkSessionId(player, al);
//		} else if (pId == SdkGateServer.PID_TONGBUTUI) {
//			player.setToken(al.getToken());
//			SdkGateServer.getTbt().checkSessionId(player, al);
//		}else if (pId == SdkGateServer.PID_ANZHI) {
//			player.setToken(al.getToken());
//			SdkGateServer.getAnZhi().checkSessionId(player, al);
//		}else if (pId == SdkGateServer.PID_LENOVO) {
//			player.setToken(al.getToken());
//			SdkGateServer.getLenovo().checkSessionId(player, al);
//		}else if (pId == SdkGateServer.PID_ALIBABA) {
//			player.setToken(al.getToken());
//			SdkGateServer.getAlibaba().checkSessionId(player, al);
//		}else if (pId == SdkGateServer.PID_YINGYONGHUI) {
//			player.setToken(al.getToken());
//			SdkGateServer.getYingyonghui().checkSessionId(player, al);
//		}else if (pId == SdkGateServer.PID_VIVO) {
//			player.setToken(al.getToken());
//			SdkGateServer.getVivo().checkSessionId(player, al);
//		}else if (pId == SdkGateServer.PID_XUNLEI) {
//			player.setToken(al.getToken());
//			SdkGateServer.getXunLei().checkSessionId(player, al);
//		}else if (pId == SdkGateServer.PID_SY37) {
//			player.setToken(al.getToken());
//			SdkGateServer.getSy37().checkSessionId(player, al);
		}

		playerLoginSuccessTime = System.currentTimeMillis();
    	System.out.println ("player Login Time:" + (playerLoginSuccessTime - playerBegintime));
	}
	
}
