package XuanQu.wl91;

import java.io.UnsupportedEncodingException;

import javax.sound.sampled.AudioFormat.Encoding;

public class TesterMD5 {

	/**
	 * @param args
	 */
	 public static void main(String[] args) {
	 // TODO Auto-generated method stub
		 TesterMD5 test = new TesterMD5();
	 String Sign = "626afa2d4e52a8a8d53d83b2a43dde60";
	
	 String Act = "1";
	 String AppId = "105986";
	 String ConsumeStreamId = "5-27199-20130313101317-100-9355";
	 String CooOrderSerial = "911bc47a-839c-40b7-85bc-7e5b7feb951d";
	 String CreateTime = "2013-03-13%2010:11:58";
	 String GoodsCount = "100";
	 String GoodsId = "0";
	 String GoodsInfo = "%e5%b8%81";
//	 try {
//		GoodsInfo = test.toGBK(GoodsInfo);
//		 System.out.println("GoodsInfo=====" + GoodsInfo);
//	} catch (UnsupportedEncodingException e1) {
//		// TODO Auto-generated catch block
//		e1.printStackTrace();
//	}
	 String Note = "51";
	 String OrderMoney = "1.00";
	
	 String OriginalMoney = "1.00";
	 String PayStatus = "1";
	 String ProductName = "%e6%81%8b%e8%88%9eOL";
	 String name="";
	 
//	 try {
//		 name = new String( ProductName.getBytes("UTF-8") , "GBK");
//	} catch (UnsupportedEncodingException e1) {
//		// TODO Auto-generated catch block
//		e1.printStackTrace();
//	}

	 try {
		name = java.net.URLDecoder.decode (ProductName,"utf-8");
	} catch (UnsupportedEncodingException e) {
		// TODO Auto-generated catch block
		e.printStackTrace();
	}

//	 try {
//		name = new String(ProductName.getBytes("GBK"), "ISO-8859-1");
//	} catch (UnsupportedEncodingException e) {
//		// TODO Auto-generated catch block
//		e.printStackTrace();
//	}
//	 System.out.println("name====" + name);
//	 try {
//		 ProductName = test.toGBK(ProductName);
//		 System.out.println("ProductName=====" + ProductName);
//	} catch (UnsupportedEncodingException e1) {
//		// TODO Auto-generated catch block
//		e1.printStackTrace();
//	}
	 String Uin = "395909980";
	 String AppKey = "d0e6d106a5ed2676eb480c9f74b80cfe1071b7ef7bf527af";
	
	 String sStr = String
	 .format("{0}{1}{2}{3}{4}{5}{6}{7}{8}{9:0.00}{10:0.00}{11}{12}{13:yyyy-MM-dd HH:mm:ss}{14}",
	 AppId, Act, ProductName, ConsumeStreamId,
	 CooOrderSerial, Uin, GoodsId, GoodsInfo, GoodsCount,
	 OriginalMoney, OrderMoney, Note, PayStatus, CreateTime,
	 AppKey);
	 String signStr =
	 "1059861恋舞OL5-27199-20130313101317-100-9355911bc47a-839c-40b7-85bc-7e5b7feb951d3959099800币1001.001.005112013-03-13 10:11:58d0e6d106a5ed2676eb480c9f74b80cfe1071b7ef7bf527af";
	
//	 System.out.println(Util.getMD5(signStr));
	
	 }
}
