package XuanQu.RWGate.Config;

public class SystemSetting {
	static private int HeatBeatTime = 15;
	static private int DropTimeout = 3;
	//static private int DropTimeout = 1;


	public static int getHeatBeatTime() {
		return HeatBeatTime;
	}
	public static void setHeatBeatTime(int heatBeatTime) {
		HeatBeatTime = heatBeatTime;
	}
	public static int getDropTimeout() {
		return DropTimeout;
	}
	public static void setDropTimeout(int dropTimeout) {
		DropTimeout = dropTimeout;
	}

}
