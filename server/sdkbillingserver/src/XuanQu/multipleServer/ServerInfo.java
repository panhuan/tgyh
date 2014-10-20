package XuanQu.multipleServer;

public class ServerInfo {
	//服务器id
	private String serverid;
	// 服务器 IP
	private String ip;
	// 服务器 Port
	private int port;

	public String getServerid() {
		return serverid;
	}

	public void setServerid(String serverid) {
		this.serverid = serverid;
	}

	public String getIp() {
		return ip;
	}

	public void setIp(String ip) {
		this.ip = ip;
	}

	public int getPort() {
		return port;
	}

	public void setPort(int port) {
		this.port = port;
	}
}
