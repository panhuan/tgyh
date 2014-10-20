package XuanQu.RWGate;

import java.util.List;

import org.apache.log4j.PropertyConfigurator;
import org.apache.mina.core.session.IoSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import XuanQu.PPHelp.HttpPPHelp;
import XuanQu.RWGate.Config.RWConfigData;
import XuanQu.UCWeb.HttpUCWeb;
import XuanQu.alibaba.HttpAlibaba;
import XuanQu.anzhi.HttpAnZhi;
import XuanQu.baidu.HttpBaiDu;
import XuanQu.cmcc.HttpCMCC;
import XuanQu.ddl.HttpDDL;
import XuanQu.downjoy.HttpDownjoy;
import XuanQu.gamecenter.HttpGameCenter;
import XuanQu.httpserver.HttpRequestMessage;
import XuanQu.i4399.HttpI4399;
import XuanQu.kingsoft.HttpKingSoft;
import XuanQu.kuaiyong.HttpKuaiYong;
import XuanQu.kuwo.HttpKuWo;
import XuanQu.lenovo.HttpLENOVO;
import XuanQu.miui.HttpMIUI;
import XuanQu.multipleServer.ServerInfo;
import XuanQu.multipleServer.TcpUtil;
import XuanQu.oppo.HttpOPPO;
import XuanQu.qh360.HttpQH360;
import XuanQu.qh360.HttpQH360Handler;
import XuanQu.sina.HttpSina;
import XuanQu.sy37.HttpSy37;
import XuanQu.tongbutui.HttpTongBuTui;
import XuanQu.ttdt.HttpTTDT;
import XuanQu.vivo.HttpVivo;
import XuanQu.wandoujia.HttpWanDouJia;
import XuanQu.wl91.HttpWL91;
import XuanQu.xunlei.HttpXunLei;
import XuanQu.yingyonghui.HttpYYH;

public class SdkBillingServer
{
	private static final Logger logger = LoggerFactory
			.getLogger(SdkBillingServer.class);

	public static final short PID_DDIANLE = (short) 1;
	public static final short PID_DOWNJOY = (short) 2;
	public static final short PID_UCWEB = (short) 3;
	public static final short PID_WL91 = (short) 5;// 91
	public static final short PID_MIUI = (short) 6;// 小米
	public static final short PID_IOS = (short) 7;// ios内置付费
	public static final short PID_QH360 = (short) 8;// 奇虎360
	public static final short PID_BAIDU = (short) 9;// 百度
	public static final short PID_KUWO = (short) 10;// 酷我
	public static final short PID_4399 = (short) 11;// 4399
	public static final short PID_PPHELP = (short) 12;
	public static final short PID_TTDT = (short) 13;// ttdt
	public static final short PID_KINGSOFT = (short) 14;// 金山
	public static final short PID_EFUNFUN = (short) 15;// 台湾
	public static final short PID_GAMECENTER = (short) 16;// gamecenter
	public static final short PID_DDL=(short)18;//自己的平台
	public static final short PID_OPPO=(short)19;//oppo
	public static final short PID_WANDOUJIA=(short)20;//豌豆荚
	public static final short PID_KUAIYONG = (short)21;//快用
	public static final short PID_TONGBUTUI = (short)22;//同步推
	public static final short PID_ANZHI=(short)23;//安智
	public static final short PID_LENOVO=(short)24;//联想 
	public static final short PID_ALIBABA=(short)25;//阿里巴巴
	public static final short PID_YINGYONGHUI=(short)26;//应用汇
	public static final short PID_VIVO=(short)28;//vivo
	public static final short PID_XUNLEI = (short)29;//迅雷
	public static final short PID_SY37 = (short)30;  //sy37
	public static final short PID_CMCC = (short)31;// 移动MM
	
	// 服务器编号
	public static int serverId;
	public static List<ServerInfo> multipleServers;

	public static int getServerId() {
		return serverId;
	}

	public static void setServerId(int serverId) {
		SdkBillingServer.serverId = serverId;
	}

	public SdkBillingServer() {
	}

	public static void main(String args[]) throws Exception {
		String home = "./"; //System.getenv("SANP_HOME");
		String logproper = home + "log4j.properties";
		PropertyConfigurator.configure(logproper);

		SdkBillingServer pServer = new SdkBillingServer();
		pServer.ServerMain();
		
//		HttpDownjoy httpdownjoy = new HttpDownjoy();
//		httpdownjoy.RunHttp();
//
//		HttpUCWeb httpucweb = new HttpUCWeb();
//		httpucweb.RunHttp();
//
//		// 91
//		HttpWL91 httpWL91 = new HttpWL91();
//		httpWL91.RunHttp();
//
//		// 小米
//		HttpMIUI httpMIUI = new HttpMIUI();
//		httpMIUI.RunHttp();

		// 360
		HttpQH360 httpQh360 = new HttpQH360();
		httpQh360.RunHttp();
		
		// CMCC 暂时不通,decode有问题
//		HttpCMCC httpCMCC = new HttpCMCC();
//		httpCMCC.RunHttp();
		
//		// baidu
//		HttpBaiDu httpBaiDu = new HttpBaiDu();
//		httpBaiDu.RunHttp();
//
//		HttpKuWo httpKuWo = new HttpKuWo();
//		httpKuWo.RunHttp();
//
//		HttpI4399 httpI4399 = new HttpI4399();
//		httpI4399.RunHttp();
//
//		HttpPPHelp httpPPHelp = new HttpPPHelp();
//		httpPPHelp.RunHttp();
//
//		HttpKingSoft httpKingSoft = new HttpKingSoft();
//		httpKingSoft.RunHttp();
//
//		HttpTTDT httpTtdt = new HttpTTDT();
//		httpTtdt.RunHttp();
//		
//		HttpGameCenter httpGameCenter = new HttpGameCenter();
//		httpGameCenter.RunHttp();
//		
//		HttpDDL httpDDL = new HttpDDL();
//		httpDDL.RunHttp();
//		
//		HttpSina httpSina=new HttpSina();
//		httpSina.RunHttp();
//		
//		HttpOPPO httpOPPO=new HttpOPPO();
//		httpOPPO.RunHttp();
//		
//		HttpWanDouJia httpWanDouJia = new HttpWanDouJia();
//		httpWanDouJia.RunHttp();
//		
//		HttpKuaiYong httpKuaiYong = new HttpKuaiYong();
//		httpKuaiYong.RunHttp();
//		
//		HttpTongBuTui httpTongBuTui = new HttpTongBuTui();
//		httpTongBuTui.RunHttp();
//		
//		HttpAnZhi httpAnZhi=new HttpAnZhi();
//		httpAnZhi.RunHttp();
//		
//		HttpLENOVO httpLENOVO=new HttpLENOVO();
//		httpLENOVO.RunHttp();
//		
//		HttpAlibaba alibaba=new HttpAlibaba();
//		alibaba.RunHttp();
//		
//		HttpYYH httpYyh=new HttpYYH();
//		httpYyh.RunHttp();
//		
//		HttpVivo httpVivo=new HttpVivo();
//		httpVivo.RunHttp();
//		
//		HttpXunLei httpXunLei = new HttpXunLei();
//		httpXunLei.RunHttp();
//		
//		HttpSy37 httpSy37 = new HttpSy37();
//		httpSy37.RunHttp();
		
//		pServer.testPay();
	}

	protected void ServerMain() {
		logger.info("Server Begin");

		RWConfigData Config = new RWConfigData();
		Config.IniConfigData();
		
		// 服务器列表
		multipleServers = Config.getServers();
		
		TcpUtil.Initial(multipleServers);
	}
	
	protected void testPay() {

		HttpQH360Handler handler = new HttpQH360Handler();
		handler.testOrder();
	}
}