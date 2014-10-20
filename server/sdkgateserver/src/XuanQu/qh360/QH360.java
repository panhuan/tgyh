package XuanQu.qh360;

import java.util.HashMap;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import net.sf.json.JSONObject;
import net.sf.json.util.JSONTokener;
import XuanQu.multipleServer.TcpUtil;
import XuanQu.qh360.model.PlayerInfo;
import XuanQu.qh360.model.SessionIdResponse;
import XuanQu.qh360.util.QException;
import XuanQu.qh360.util.QOAuth2;

/**
 * @author zhanghuaming
 * 
 */
public class QH360 {
	private static final Logger logger = LoggerFactory.getLogger(QH360.class);
	
	private String client_id;

	private String client_secret;

	private String serverUrl_CheckSession;
	private String serverUrl_getPlayerInfo;

	private String grant_type;

	private String redirect_uri;

	private String fields;

	private String host = "";
	private String scope_basic = "";

	public void Init() throws Exception {
		serverUrl_CheckSession = Util.getConfig("serverUrl_CheckSession");
		serverUrl_getPlayerInfo = Util.getConfig("serverUrl_getPlayerInfo");
		client_id = Util.getConfig("client_id");
		client_secret = Util.getConfig("client_secret");
		grant_type = Util.getConfig("grant_type");
		redirect_uri = Util.getConfig("redirect_uri");
		fields = Util.getConfig("fields");
		host = Util.getConfig("host");
		scope_basic = Util.getConfig("scope_basic");
	}

	/**
	 * 检查用户登陆sessionId是否有效
	 * 
	 * @param aPlayer
	 * @param aRequest
	 */
	public void login(final String param[]) {
		if (param == null) {
			return;
		}
		
		if (param.length < 3) {
			return;
		}
		
		// 用户登录的authCode
		String code = param[0];
		String playerGuid = param[1];
		String serverId = param[2];

		HashMap<String, Object> token = null;
		HashMap<String, Object> user = null;

		try {
			QOAuth2 qoauth2 = new QOAuth2(client_id, client_secret,
					serverUrl_CheckSession, redirect_uri, scope_basic, host);

			token = qoauth2.getAccessTokenByCode(code, null);
			user = qoauth2.userMe(token.get("access_token").toString());

			String str_token = net.minidev.json.JSONObject.toJSONString(token);

			JSONTokener jsonParser = new JSONTokener(str_token);
			// 此时还未读取任何json文本，直接读取就是一个JSONObject对象。
			JSONObject resultJson = (JSONObject) jsonParser.nextValue();
			// 接下来的就是JSON对象的操作了

			SessionIdResponse sResponse = new SessionIdResponse();
			sResponse.setAccess_token((String) resultJson
					.get("access_token"));

			String str_user = net.minidev.json.JSONObject.toJSONString(user);

			JSONTokener jsonUser = new JSONTokener(str_user);
			// 此时还未读取任何json文本，直接读取就是一个JSONObject对象。
			JSONObject resultUser = (JSONObject) jsonUser.nextValue();

			PlayerInfo pInfo = new PlayerInfo();
			pInfo.setId((String) resultUser.get("id"));
			pInfo.setName((String)resultUser.getString("name"));

			if (sResponse.getAccess_token() != null) {
				
				StringBuilder msg = new StringBuilder();
				msg.append("login");
				msg.append(",");
				msg.append(playerGuid);
				msg.append(",");
				msg.append(sResponse.getAccess_token());
				msg.append(",");
				msg.append(pInfo.getId());
				msg.append(",");
				msg.append(pInfo.getName());
				msg.append(",");
				msg.append(serverId);
				sendToServer(msg.toString());
			}
			
		} catch (QException e1) {

			StringBuilder msg = new StringBuilder();
			msg.append("login");
			msg.append(",");
			msg.append(playerGuid);
			msg.append(",");
			msg.append("");
			msg.append(",");
			msg.append("");
			msg.append(",");
			msg.append("");
			msg.append(",");
			msg.append(serverId);
			sendToServer(msg.toString());

			StringBuilder log = new StringBuilder();
			log.append(e1.getMessage());
			log.append(",");
			log.append(code);
			log.append(",");
			log.append(playerGuid);
			log.append(",");
			log.append(serverId);
			logger.warn(log.toString());
			
			e1.printStackTrace();
			
		} catch (Exception e) {

			StringBuilder msg = new StringBuilder();
			msg.append("login");
			msg.append(",");
			msg.append(playerGuid);
			msg.append(",");
			msg.append("");
			msg.append(",");
			msg.append("");
			msg.append(",");
			msg.append("");
			msg.append(",");
			msg.append(serverId);
			sendToServer(msg.toString());

			StringBuilder log = new StringBuilder();
			log.append(e.getMessage());
			log.append(",");
			log.append(code);
			log.append(",");
			log.append(playerGuid);
			log.append(",");
			log.append(serverId);
			logger.warn(log.toString());
			
			e.printStackTrace();
		}
	}
	
	public void sendToServer(final String msg) {
		// 发送到1号服务器(gc)
		TcpUtil.send("1", msg);
	}
}
