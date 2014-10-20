package XuanQu.UCWeb;

import java.util.HashMap;
import java.util.Map;

import XuanQu.UCWeb.model.Game;
import XuanQu.UCWeb.model.SidInfoResponse;
import XuanQu.UCWeb.model.UcidBindCreateResponse;

public class UCWeb {
	// sdk server的接口地址
	private static String serverUrl = "";
	// 游戏合作商编号
	private static int cpId = 0;
	// 游戏编号
	private static int gameId = 0;
	// 游戏发行渠道编号
	private static String channelId = "";
	// 游戏服务器编号
	private static int serverId = 0;
	// 分配给游戏合作商的接入密钥,请做好安全保密
	private static String apiKey = "";

	public void Init() throws Exception {
		serverUrl = Util.getConfig("serverUrl");
		cpId = Integer.valueOf(Util.getConfig("cpId"));
		gameId = Integer.valueOf(Util.getConfig("gameId"));
		channelId = Util.getConfig("channelId");
		serverId = Integer.valueOf(Util.getConfig("serverId"));
		apiKey = Util.getConfig("apiKey");
	}

	/**
	 * sid用户会话验证。
	 * 
	 * @param sid
	 *            从游戏客户端的请求中获取的sid值
	 * @throws Exception
	 */
//	public void sidInfo(Player aPlayer, XQClientAccount_Login aRequest) {
//		if (aRequest != null && aPlayer != null) {
//			String sid = aRequest.getToken();
//			Map<String, Object> params = new HashMap<String, Object>();
//			params.put("id", System.currentTimeMillis());// 当前系统时间
//			params.put("service", "ucid.user.sidInfo");
//
//			Game game = new Game();
//			game.setCpId(cpId);// cpid是在游戏接入时由UC平台分配，同时分配相对应cpId的apiKey
//			game.setGameId(gameId);// gameid是在游戏接入时由UC平台分配
//			game.setChannelId(channelId);// channelid是在游戏接入时由UC平台分配
//			game.setServerId(serverId);
//
//			params.put("game", game);
//
//			Map data = new HashMap();
//			data.put("sid", sid);// 在uc sdk登录成功时，游戏客户端通过uc
//									// sdk的api获取到sid，再游戏客户端由传到游戏服务器
//			params.put("data", data);
//
//			params.put("encrypt", "md5");
//			/*
//			 * 签名规则=cpId+签名内容+apiKey
//			 * 假定cpId=109,apiKey=202cb962234w4ers2aaa,sid=abcdefg123456
//			 * 那么签名原文109sid=abcdefg123456202cb962234w4ers2aaa
//			 * 签名结果6e9c3c1e7d99293dfc0c81442f9a9984
//			 */
//			String signSource = cpId + "sid=" + sid + apiKey;// 组装签名原文
//			String sign = Util.getMD5Str(signSource);// MD5加密签名
//
//			params.put("sign", sign);
//
//			try {
//				String body = Util.encodeJson(params);
//				String result = Util.doPost(serverUrl, body);// http
//																// post方式调用服务器接口,请求的body内容是参数json格式字符串
//
//				SidInfoResponse rsp = (SidInfoResponse) Util.decodeJson(result,
//						SidInfoResponse.class);// 反序列化
//				if (rsp != null && rsp.getState().getCode() == (int) 1
//						&& rsp.getData().getUcid() > 0) {// 反序列化成功，输出其对象内容
//					XQClientAccount_Login al2 = (XQClientAccount_Login) aRequest;
//					al2.setPUID(rsp.getData().getUcid() + "");
//					al2.setName(rsp.getData().getNickName());
//
//					aPlayer.setPID(al2.getPID());
//					aPlayer.setPUID(al2.getPUID());
//					aPlayer.setToken(al2.getToken());
//					aPlayer.setName(al2.getName());
//
//					XQServerAccountLoginMsg sal2 = al2
//							.ToXQServerAccountLoginMsg();
//					sal2.setGateSession(aPlayer.getGateSessionID());
//					aPlayer.PlayerSendMessgeToServer(sal2, sal2.getType());
//				} else {
//					aPlayer.getSession().close(true);
//				}
//			} catch (Exception e) {
//				e.printStackTrace();
//			}
//		}
//	}

	/**
	 * ucid和游戏官方帐号绑定接口。
	 * 
	 * @param gameUser
	 *            游戏官方帐号
	 * @throws Exception
	 */
	public static void ucid_bind_create(String gameUser) throws Exception {
//		System.out.println("开始调用ucid和游戏官方帐号绑定接口");
		Map<String, Object> params = new HashMap<String, Object>();
		params.put("id", System.currentTimeMillis());// 当前系统时间
		params.put("service", "ucid.bind.create");

		Game game = new Game();
		game.setCpId(cpId);// cpid是在游戏接入时由UC平台分配，同时分配相对应cpId的apiKey
		game.setGameId(gameId);// gameid是在游戏接入时由UC平台分配
		game.setChannelId(channelId);// channelid是在游戏接入时由UC平台分配
		// serverid是在游戏接入时由UC平台分配，
		// 若存在多个serverid情况，则根据用户选择进入的某一个游戏区而确定。
		// 若在调用该接口时未能获取到具体哪一个serverid，则此时默认serverid=0
		game.setServerId(serverId);

		params.put("game", game);

		Map data = new HashMap();
		data.put("gameUser", gameUser);// 游戏官方帐号
		params.put("data", data);

		params.put("encrypt", "md5");
		/*
		 * 签名规则=cpId+签名内容+apiKey
		 * 假定cpId=109,apiKey=202cb962234w4ers2aaa,sid=abcdefg123456
		 * 那么签名原文109gameUser=abcd202cb962234w4ers2aaa
		 * 签名结果6bf1e3aa96b6a7030228e0b55fce072e
		 */
		String signSource = cpId + "gameUser=" + gameUser + apiKey;// 组装签名原文
		String sign = Util.getMD5Str(signSource);// MD5加密签名

		System.out.println("[签名原文]" + signSource);
		System.out.println("[签名结果]" + sign);

		params.put("sign", sign);

		String body = Util.encodeJson(params);// 把参数序列化成一个json字符串
		System.out.println("[请求参数]" + body);

		String result = Util.doPost(serverUrl, body);// http
														// post方式调用服务器接口,请求的body内容是参数json格式字符串
		System.out.println("[响应结果]" + result);// 结果也是一个json格式字符串

		UcidBindCreateResponse rsp = (UcidBindCreateResponse) Util.decodeJson(
				result, UcidBindCreateResponse.class);// 反序列化
		if (rsp != null) {// 反序列化成功，输出其对象内容
			System.out.println("[id]" + rsp.getId());
			System.out.println("[code]" + rsp.getState().getCode());
			System.out.println("[msg]" + rsp.getState().getMsg());
			System.out.println("[ucid]" + rsp.getData().getUcid());
			System.out.println("[sid]" + rsp.getData().getSid());
		} else {
			System.out.println("接口返回异常");
		}
		System.out.println("调用ucid和游戏官方帐号绑定接口结束");
	}
}
