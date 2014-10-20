package XuanQu.kuwo.model;

/**
 * 支付回调接口封装类
 * @author banshuai
 *
 */
public class PayCallbackResponse {
	private String appId; // appId
	private String cpOrderId = ""; // 开发商订单 ID
	private String cpUserInfo = ""; // 开发商透传信息
	private String uid = ""; // 用户 ID
	private String orderId = ""; // 游戏平台订单 ID
	private String orderStatus = ""; // 订单状态TRADE_SUCCESS 代表成功
	private String payFee = ""; // 支付金额，单位为分，即 0.01 米币。
	private String productCode = ""; // 商品代码
	private String productName = ""; // 商品名称
	private String productCount = ""; // 商品数量
	private String payTime = ""; // 支付时间，格式yyyy-MM-dd HH:mm:ss
	private String signature = ""; // 签名：以上参数按字母顺序排序然后进行签名。

	public String getAppId() {
		return appId;
	}

	public void setAppId(String appId) {
		this.appId = appId;
	}

	public String getCpOrderId() {
		return cpOrderId;
	}

	public void setCpOrderId(String cpOrderId) {
		this.cpOrderId = cpOrderId;
	}

	public String getCpUserInfo() {
		return cpUserInfo;
	}

	public void setCpUserInfo(String cpUserInfo) {
		this.cpUserInfo = cpUserInfo;
	}

	public String getUid() {
		return uid;
	}

	public void setUid(String uid) {
		this.uid = uid;
	}

	public String getOrderId() {
		return orderId;
	}

	public void setOrderId(String orderId) {
		this.orderId = orderId;
	}

	public String getOrderStatus() {
		return orderStatus;
	}

	public void setOrderStatus(String orderStatus) {
		this.orderStatus = orderStatus;
	}

	public String getPayFee() {
		return payFee;
	}

	public void setPayFee(String payFee) {
		this.payFee = payFee;
	}

	public String getProductCode() {
		return productCode;
	}

	public void setProductCode(String productCode) {
		this.productCode = productCode;
	}

	public String getProductName() {
		return productName;
	}

	public void setProductName(String productName) {
		this.productName = productName;
	}

	public String getProductCount() {
		return productCount;
	}

	public void setProductCount(String productCount) {
		this.productCount = productCount;
	}

	public String getPayTime() {
		return payTime;
	}

	public void setPayTime(String payTime) {
		this.payTime = payTime;
	}

	public String getSignature() {
		return signature;
	}

	public void setSignature(String signature) {
		this.signature = signature;
	}

}
