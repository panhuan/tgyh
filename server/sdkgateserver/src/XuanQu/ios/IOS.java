package XuanQu.ios;


/**
 * @author banshuai
 * 
 */
public class IOS {
	// 内付费正式server地址
	private static String ServerUrl = "";
	// 内付费测试server地址
	private static String TestServerUrl = "";

	public void Init() throws Exception {
		ServerUrl = Util.getConfig("ServerUrl");
		TestServerUrl = Util.getConfig("TestServerUrl");
	}
	
	
	//发钱了
	public int Paycoin(String product_id_String) {
		int coin_money = 0;
		if (product_id_String.equalsIgnoreCase("com.ddianle.lovedance.ddl.oneDemo")) {
			coin_money = 600;
		}
		 if (product_id_String.equalsIgnoreCase("com.ddianle.lovedance.ddl.twoDemo")) {
			coin_money = 1200;
		}
		if (product_id_String.equalsIgnoreCase("com.ddianle.lovedance.ddl.threeDemo")) {
			coin_money = 1800;
		}
		if (product_id_String.equalsIgnoreCase("com.ddianle.lovedance.ddl.fourDemo")) {
			coin_money = 3000;
		}else {
			coin_money = 3600;
		}
		return coin_money;
	}
}
