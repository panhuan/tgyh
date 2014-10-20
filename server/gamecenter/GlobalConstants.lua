
--客户端版本
CLIENT_VERSION = 1

--订单状态
ORDER_STATE_NONE				= -1	--无订单,或取消
ORDER_STATE_UNPAY 				= 0		--已下单,未支付
ORDER_STATE_CLIENT_PAYED 		= 1		--Client已支付,未被Server通知完成
ORDER_STATE_SERVER_PAYED 		= 2		--Server已支付,未通知Client
ORDER_STATE_FINISHED			= 3		--已支付,订单完成

--订单金额,配置表填的是元,360支付用的是分,换算比率为100
EXCHANGE_RATE = 100

--ERR_CODE
ERR_SUCCEED				= 0
ERR_FAILED				= 1
ERR_VERSION_UNMATCH 	= 2