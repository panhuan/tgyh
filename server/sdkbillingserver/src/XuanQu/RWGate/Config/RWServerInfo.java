package XuanQu.RWGate.Config;

public class RWServerInfo {
	private String m_strIp = null;
	private int m_nPort =0;
	public String getIP()
	{
		return m_strIp;
	}
	public int getPort()
	{
		return m_nPort;
	}
	public void setIP(String strIP)
	{
		m_strIp = strIP;
	}
	public void setPort( int nPort )
	{
		m_nPort = nPort;
	}
}
