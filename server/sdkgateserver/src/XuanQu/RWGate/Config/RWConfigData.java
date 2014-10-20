package XuanQu.RWGate.Config;

import java.io.File;
import java.util.LinkedList;
import java.util.List;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.w3c.dom.Document;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import XuanQu.multipleServer.ServerInfo;

public class RWConfigData {
	private Document m_doc = null;
	private static String SANP_HOME = "./"; 
	private static final Logger logger = LoggerFactory.getLogger(RWConfigData.class);
	public  boolean IniConfigData()
	{
		try
		{
//			SANP_HOME = System.getenv("SANP_HOME");
			String Configfilename = SANP_HOME.trim();
			if( Configfilename.lastIndexOf("/") != Configfilename.length()-1 )
			{
				Configfilename += "/";
			}
			Configfilename +="conf/config.xml";
			File f = new File(Configfilename);
		    DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();    
		    DocumentBuilder builder = factory.newDocumentBuilder();
		    m_doc = builder.parse(f);  
//		    IniSystemSetting();
		    return true;
		}
		catch(Exception e)
		{
			logger.error("Read ConfigData Failed");
		}
	    return false;
	}
//	public RWServerInfo getAccountServerInfo()
//	{
//		RWServerInfo Info = new RWServerInfo();
//		NodeList nl = m_doc.getElementsByTagName("accountserver");
//		if( nl.getLength() > 0 )
//		{
//			Node node = nl.item(0);
//			if( node != null)
//			{
//				NamedNodeMap att = node.getAttributes();
//				if( att != null && att.getLength() > 0 )
//				{
//					Node f = att.getNamedItem("ip");
//					Info.setIP(f.getNodeValue()) ;
//					f = att.getNamedItem("port");
//					Info.setPort(Integer.parseInt(f.getNodeValue()));
//				}
//			}
//		}
//		return Info;
//	}
//	public RWServerInfo getGroupServerInfo()
//	{
//		RWServerInfo Info = new RWServerInfo();
//		NodeList nl = m_doc.getElementsByTagName("groupserver");
//		if( nl.getLength() > 0 )
//		{
//			Node node = nl.item(0);
//			if( node != null)
//			{
//				NamedNodeMap att = node.getAttributes();
//				if( att != null && att.getLength() > 0 )
//				{
//					Node f = att.getNamedItem("ip");
//					Info.setIP(f.getNodeValue()) ;
//					f = att.getNamedItem("port");
//					Info.setPort(Integer.parseInt(f.getNodeValue()));
//				}
//			}
//		}
//		return Info;
//	}
	public List<ServerInfo> getServers()
	{
		List<ServerInfo> InfoList = new LinkedList<ServerInfo>();
		NodeList nl = m_doc.getElementsByTagName("server");
		if( nl.getLength() > 0 )
		{
			for(int i=0;i<nl.getLength();i++ )
			{
				Node node = nl.item(i);
				if( node != null)
				{
					ServerInfo Info = new ServerInfo();
					NamedNodeMap att = node.getAttributes();
					if( att != null && att.getLength() > 0 )
					{
						Node f = att.getNamedItem("id");
						Info.setServerid(f.getNodeValue()) ;
						f = att.getNamedItem("ip");
						Info.setIp(f.getNodeValue());
						f = att.getNamedItem("port");
						Info.setPort(Integer.parseInt(f.getNodeValue()));
						InfoList.add(Info);
					}
				}
			}
		}
		return InfoList;
	}
	
//	public ServerSetting getServerSetting()
//	{
//		ServerSetting Setting = new ServerSetting();
//		NodeList nl = m_doc.getElementsByTagName("serversetting");
//		if( nl.getLength() > 0 )
//		{
//			Node node = nl.item(0);
//			if( node != null)
//			{
//				NamedNodeMap att = node.getAttributes();
//				if( att != null && att.getLength() > 0 )
//				{
//					Node f = att.getNamedItem("port");
//					Setting.setPort(Integer.parseInt(f.getNodeValue()));
//					f = att.getNamedItem("serverid");
//					Setting.setServerid(Integer.parseInt(f.getNodeValue()));
//				}
//			}
//		}
//		return Setting;
//	}
//	
//	public void IniSystemSetting()
//	{
////		SystemSetting sys = new SystemSetting();
//		NodeList nl = m_doc.getElementsByTagName("SystemSetting");
//		if( nl.getLength() > 0 )
//		{
//			Node node = nl.item(0);
//			if( node != null)
//			{
//				NamedNodeMap att = node.getAttributes();
//				if( att != null && att.getLength() > 0 )
//				{
//					Node f = att.getNamedItem("heartbeattime");
//					SystemSetting.setHeatBeatTime(Integer.parseInt(f.getNodeValue())) ;
//					f = att.getNamedItem("droptimeout");
//					SystemSetting.setDropTimeout(Integer.parseInt(f.getNodeValue()));
//				}
//			}
//		}
////		return sys;
//	}

}
