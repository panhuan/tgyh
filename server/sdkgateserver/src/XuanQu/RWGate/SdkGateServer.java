package XuanQu.RWGate;

import java.util.List;

import org.apache.log4j.PropertyConfigurator;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import XuanQu.PPHelp.PPHelp;
import XuanQu.RWGate.Config.RWConfigData;
import XuanQu.UCWeb.UCWeb;
import XuanQu.alibaba.Alibaba;
import XuanQu.anzhi.AnZhi;
import XuanQu.baidu.BaiDu;
import XuanQu.ddl.DDL;
import XuanQu.downjoy.Downjoy;
import XuanQu.gamecenter.GameCenter;
import XuanQu.i4399.I4399;
import XuanQu.ios.IOS;
import XuanQu.kingsoft.KingSoft;
import XuanQu.kuaiyong.KuaiYong;
import XuanQu.kuwo.KuWo;
import XuanQu.lenovo.Lenovo;
import XuanQu.miui.MIUI;
import XuanQu.multipleServer.ServerInfo;
import XuanQu.multipleServer.TcpUtil;
import XuanQu.oppo.OPPO;
import XuanQu.qh360.QH360;
import XuanQu.sy37.Sy37;
import XuanQu.tongbutui.TongBuTui;
import XuanQu.ttdt.TTDT;
import XuanQu.vivo.Vivo;
import XuanQu.wandoujia.WanDouJia;
import XuanQu.wl91.Wl91;
import XuanQu.xunlei.XunLei;
import XuanQu.yingyonghui.YingYongHui;

public class SdkGateServer
{
	private static final Logger logger = LoggerFactory
			.getLogger(SdkGateServer.class);
	
	private static Downjoy downjoy = null;
	private static UCWeb ucweb = null;
	private static Wl91 wl91 = null;// 91
	private static MIUI miui = null;// 小米
	private static IOS ios = null;// ios内置付费
	private static QH360 qh360 = null;// 360
	private static BaiDu baidu = null;// 百度
	private static KuWo kuwo = null;// 酷我
	private static I4399 i4399 = null;// 4399
	private static PPHelp pphelp = null; // ios PP助手
	private static KingSoft kingSoft = null;// 金山
	private static TTDT ttdt = null;// 天天动听
	private static GameCenter gamecenter = null; // GameCenter
	private static DDL ddl = null;// 自己的平台
	private static OPPO oppo = null;//
	private static WanDouJia wdj = null;// 豌豆荚
	private static KuaiYong ky = null;//快用
	private static TongBuTui tbt = null;//同步推
	private static AnZhi anZhi=null;//安智
	private static Lenovo lenovo=null;//联想
	private static Alibaba alibaba=null;//阿里巴巴
	private static YingYongHui yingyonghui=null;//应用汇
	private static Vivo vivo=null; //vivo
	private static XunLei xunlei = null; //迅雷
	private static Sy37 sy37 = null; //sy37
	
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
	public static final short PID_GameCenter = (short) 16;
	public static final short PID_DDL = (short) 18;// 点点乐平台
	public static final short PID_OPPO = (short) 19;// oppo音乐手机
	public static final short PID_WANDOUJIA = (short) 20;//豌豆荚
	public static final short PID_KUAIYONG = (short) 21;//快用
	public static final short PID_TONGBUTUI = (short) 22;//同步推
	public static final short PID_ANZHI=(short)23;//安智
	public static final short PID_LENOVO=(short)24;//联想
	public static final short PID_ALIBABA=(short)25;//阿里巴巴
	public static final short PID_YINGYONGHUI=(short)26;//应用汇
	public static final short PID_VIVO=(short)28;//vivo
	public static final short PID_XUNLEI = (short)29; //迅雷
	public static final short PID_SY37 = (short)30;  //sy37

	// 服务器编号
	public static int serverId;
	public static List<ServerInfo> multipleServers;

	public static int getServerId() {
		return serverId;
	}

	public static void setServerId(int serverId) {
		SdkGateServer.serverId = serverId;
	}
	
	public SdkGateServer() {
	}

	public static void main(String args[]) throws Exception {
//		String home = System.getenv("SANP_HOME");
//		String logproper = home + "log4j.properties";
		String logproper = "./log4j.properties";
		PropertyConfigurator.configure(logproper);

//		downjoy = new Downjoy();
//		downjoy.Init();
//
//		ucweb = new UCWeb();
//		ucweb.Init();
//
//		// 91
//		wl91 = new Wl91();
//		wl91.Init();
//
//		// 小米
//		miui = new MIUI();
//		miui.Init();
//
//		// ios内置付费
//		ios = new IOS();
//		ios.Init();
//
		// 360
		qh360 = new QH360();
		qh360.Init();
//
//		// baidu
//		baidu = new BaiDu();
//		baidu.Init();
//
//		kuwo = new KuWo();
//		kuwo.Init();
//
//		i4399 = new I4399();
//		i4399.Init();
//
//		pphelp = new PPHelp();
//		pphelp.Init();
//
//		kingSoft = new KingSoft();
//		kingSoft.Init();
//
//		ttdt = new TTDT();
//		ttdt.Init();
//
//		gamecenter = new GameCenter();
//		gamecenter.Init();
//
//		ddl = new DDL();
//		ddl.Init();
//
//		oppo = new OPPO();
//		oppo.Init();
//		
//		wdj = new WanDouJia();
//		wdj.Init();
//		
//		ky = new KuaiYong();
//		ky.Init();
//		
//		tbt = new TongBuTui();
//		tbt.Init();
//		
//		anZhi=new AnZhi();
//		anZhi.Init();
//		
//		lenovo=new Lenovo();
//		lenovo.Init();
//		
//		alibaba=new Alibaba();
//		alibaba.Init();
//		
//		yingyonghui=new YingYongHui();
//		yingyonghui.Init();
//		
//		vivo=new Vivo();
//		vivo.Init();
//		
//		xunlei = new XunLei();
//		xunlei.Init();
//		
//		sy37 = new Sy37();
//		sy37.Init();
		

		SdkGateServer pServer = new SdkGateServer();
		pServer.ServerMain();
	}

	protected void ServerMain() {
		logger.info("Server Begin");

		RWConfigData Config = new RWConfigData();
		Config.IniConfigData();

		// 服务器列表
		multipleServers = Config.getServers();
		
		TcpUtil.Initial(multipleServers);
	}

	public static Downjoy getDownjoy() {
		return downjoy;
	}

	public static UCWeb getUCWeb() {
		return ucweb;
	}

	public static Wl91 getWl91() {
		return wl91;
	}

	public static MIUI getMiui() {
		return miui;
	}

	public static IOS getIOS() {
		return ios;
	}

	public static QH360 getQh360() {
		return qh360;
	}

	public static BaiDu getBaidu() {
		return baidu;
	}

	public static KuWo getKuwo() {
		return kuwo;
	}

	public static I4399 getI4399() {
		return i4399;
	}

	public static PPHelp getPPHelp() {
		return pphelp;
	}

	public static KingSoft getKingSoft() {
		return kingSoft;
	}

	public static TTDT getTtdt() {
		return ttdt;
	}

	public static GameCenter getGameCenter() {
		return gamecenter;
	}

	public static DDL getDdl() {
		return ddl;
	}

	public static OPPO getOppo() {
		return oppo;
	}

	public static WanDouJia getWdj() {
		return wdj;
	}

	public static KuaiYong getKy() {
		return ky;
	}

	public static TongBuTui getTbt() {
		return tbt;
	}
	
	public static AnZhi getAnZhi() {
		return anZhi;
	}

	public static Lenovo getLenovo() {
		return lenovo;
	}
	
	public static Alibaba getAlibaba() {
		return alibaba;
	}
	
	public static YingYongHui getYingyonghui() {
		return yingyonghui;
	}
	
	public static Vivo getVivo() {
		return vivo;
	}
	
	public static XunLei getXunLei() {
		return xunlei;
	}
	
	public static Sy37 getSy37() {
		return sy37;
	}
}