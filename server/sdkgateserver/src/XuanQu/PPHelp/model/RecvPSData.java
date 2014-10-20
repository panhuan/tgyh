package XuanQu.PPHelp.model;

public class RecvPSData
{
	private int len;
	private int command;
	private int status;
	private String username;
	private long userid;
	
	public static int MiniObjectSize = 3*4+1+8;
	

	public RecvPSData() {
		this.len = 0;
		this.command = 0;
		this.status = 0;
		this.username = null;
		this.userid = 0;
	}
	
	
	public RecvPSData(int len, int command, int status, String username,
			long userid) {
		super();
		this.len = len;
		this.command = command;
		this.status = status;
		this.username = username;
		this.userid = userid;
	}

	public int getLen() {
		return len;
	}
	public void setLen(int len) {
		this.len = len;
	}
	public int getCommand() {
		return command;
	}
	public void setCommand(int command) {
		this.command = command;
	}
	public int getStatus() {
		return status;
	}
	public void setStatus(int status) {
		this.status = status;
	}
	public String getUsername() {
		return username;
	}
	public void setUsername(String username) {
		this.username = username;
	}
	public long getUserid() {
		return userid;
	}
	public void setUserid(long userid) {
		this.userid = userid;
	}
}
