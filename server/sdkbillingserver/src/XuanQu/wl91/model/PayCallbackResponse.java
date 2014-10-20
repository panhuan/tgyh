package XuanQu.wl91.model;

/**
 * @author banshuai
 * 查询支付购买结果(Act=1) 
 */
public class PayCallbackResponse {

	private String ConsumeStreamId;// 消费流水号，平台流水号
	private String CooOrderSerial;// 商户订单号，购买时应用传入，原样返回给应用
	private String MerchantId;// 商户 ID
	private String AppId;// 应用 ID
	private String ProductName;// 应用名称
	private String Uin;// 91 账号 ID，购买时应用传入，原样返回给应用
	private String GoodsId;// 商品 ID，购买时应用传入，原样返回给应用
	private String GoodsInfo;// 商品名称，购买时应用传入，原样返回给应用
	private String GoodsCount;// 商品数量，购买时应用传入，原样返回给应用
	private String OriginalMoney;// 原价(格式：0.00)，购买时应用传入的单价*总数，总原价
	private String OrderMoney;// 实际价格(格式：0.00)，购买时应用传入的单价*总数，总实际价格
	private String Note;// 即支付描述（客户端 API 参数中的 payDescription 字段） 购买时客户端应用通过 API
						// 传入，原样返回给应用服务器 开发者可以利用该字段，定义自己的扩展数据。例如区分游戏服务器
	private String PayStatus;// 支付状态：0=失败，1=成功，2=正在处理中 (仅当
								// ErrorCode=1，表示接口调用成功时，才需要检查此字段状态，开发商需要根据此参数状态发放物品)
	private String CreateTime;// 创建时间(yyyy-MM-dd HH:mm:ss)
	private String Sign;// 以上参数的 MD5 值，其中 AppKey 为 91SNS平台分配的应用密钥
						// String.Format("{0}{1}{2}{3}{4}{5}{6}{7}{8}{9:0.00}{10:0.00}{11}{12}{13:yyyy-MM-dd HH:mm:ss}{14}",
						// ConsumeStreamId, CooOrderSerial, MerchantId, AppId,
						// ProductName, Uin, GoodsId, GoodsInfo, GoodsCount,
						// OriginalMoney, OrderMoney, Note, PayStatus,
						// CreateTime, AppKey).HashToMD5Hex()
	private String ErrorCode;// 错误码(0=失败，1=成功，2= AppId 无效，3= Act 无效，4=参数无效，5= Sign 无效, 11=没有该订单) 
	private String ErrorDesc;// 错误描述

	public String getConsumeStreamId() {
		return ConsumeStreamId;
	}

	public void setConsumeStreamId(String consumeStreamId) {
		ConsumeStreamId = consumeStreamId;
	}

	public String getCooOrderSerial() {
		return CooOrderSerial;
	}

	public void setCooOrderSerial(String cooOrderSerial) {
		CooOrderSerial = cooOrderSerial;
	}

	public String getMerchantId() {
		return MerchantId;
	}

	public void setMerchantId(String merchantId) {
		MerchantId = merchantId;
	}

	public String getAppId() {
		return AppId;
	}

	public void setAppId(String appId) {
		AppId = appId;
	}

	public String getProductName() {
		return ProductName;
	}

	public void setProductName(String productName) {
		ProductName = productName;
	}

	public String getUin() {
		return Uin;
	}

	public void setUin(String uin) {
		Uin = uin;
	}

	public String getGoodsId() {
		return GoodsId;
	}

	public void setGoodsId(String goodsId) {
		GoodsId = goodsId;
	}

	public String getGoodsInfo() {
		return GoodsInfo;
	}

	public void setGoodsInfo(String goodsInfo) {
		GoodsInfo = goodsInfo;
	}

	public String getGoodsCount() {
		return GoodsCount;
	}

	public void setGoodsCount(String goodsCount) {
		GoodsCount = goodsCount;
	}

	public String getOriginalMoney() {
		return OriginalMoney;
	}

	public void setOriginalMoney(String originalMoney) {
		OriginalMoney = originalMoney;
	}

	public String getOrderMoney() {
		return OrderMoney;
	}

	public void setOrderMoney(String orderMoney) {
		OrderMoney = orderMoney;
	}

	public String getNote() {
		return Note;
	}

	public void setNote(String note) {
		Note = note;
	}

	public String getPayStatus() {
		return PayStatus;
	}

	public void setPayStatus(String payStatus) {
		PayStatus = payStatus;
	}

	public String getCreateTime() {
		return CreateTime;
	}

	public void setCreateTime(String createTime) {
		CreateTime = createTime;
	}

	public String getSign() {
		return Sign;
	}

	public void setSign(String sign) {
		Sign = sign;
	}

	public String getErrorCode() {
		return ErrorCode;
	}

	public void setErrorCode(String errorCode) {
		ErrorCode = errorCode;
	}

	public String getErrorDesc() {
		return ErrorDesc;
	}

	public void setErrorDesc(String errorDesc) {
		ErrorDesc = errorDesc;
	}

}
