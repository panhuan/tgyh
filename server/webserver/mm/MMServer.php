<?php
/**
 * M-Market计费平台
 * 外部接口Demo
 * 接收MMarket平台服务器通知接口
 * 
 */

/**
 * 根据订单通知数据，根据应用,获取应用AppKey
 * 
 */		
$AppKey			= array();
$AppKey["26AA72014EB4B557"]	= "qihoo";
$AppKey["CBE3C3C0454416C1"]	= "chuangwei";
$LogDB			= "10.171.194.6";
$LogDBSource	= "kaixin_log";
$LogDBUsername	= "kaixin";
$LogDBPassword	= "kaixinpass";
$GCIp			= "127.0.0.1";
$GCPort			= 8003;

 /**
  *  加载 MMarket.class.php 
  */
require_once dirname(__FILE__).'/MMarket.class.php';

/**
 *  创建 class MMarket
 */
$MMarket = new MMarket();

function writeBilling($tradeid, $chanel, $key, $value) {
	global $LogDB, $LogDBUsername, $LogDBPassword, $LogDBSource;
	
	$con = mysql_connect($LogDB, $LogDBUsername, $LogDBPassword);
	if (!$con) {
		die('Could not connect: ' . mysql_error());
	}
	mysql_select_db($LogDBSource, $con) or die('Could not select db: ' . mysql_error());
	
	mysql_query("
		CREATE TABLE IF NOT EXISTS `billings` (
			`tradeid` varchar(64) NOT NULL,
			`date` datetime NOT NULL,
			`chanel` varchar(64) NOT NULL,
			`key` varchar(64) NOT NULL,
			`value` text NOT NULL,
			PRIMARY KEY `tradeid_pk` (`tradeid`),
			INDEX `date_idx` (`date`),
			INDEX `key_idx` (`key`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='contains all users informations';",
		$con);

	mysql_query(
		"INSERT IGNORE INTO `billings` SET
			`tradeid` = '" . $tradeid . "',
			`date` = NOW(),
			`chanel` = '" . $chanel . "',
			`key` = '" . $key . "',
			`value` = '" . $value . "'",
		$con);

	mysql_close($con);
}

function writeLog($key, $value) {
	global $LogDB, $LogDBUsername, $LogDBPassword, $LogDBSource;
	
	$con = mysql_connect($LogDB, $LogDBUsername, $LogDBPassword);
	if (!$con) {
		die('Could not connect: ' . mysql_error());
	}
	mysql_select_db($LogDBSource, $con) or die('Could not select db: ' . mysql_error());
	
	mysql_query("
		CREATE TABLE IF NOT EXISTS `logs` (
			`date` datetime NOT NULL,
			`key` varchar(64) NOT NULL,
			`value` text NOT NULL,
			INDEX `date_idx` (`date`),
			INDEX `key_idx` (`key`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='contains all users informations';",
		$con);

	mysql_query(
		"INSERT IGNORE INTO `logs` SET
			`date` = NOW(),
			`key` = '" . $key . "',
			`value` = '" . $value . "'",
		$con);

	mysql_close($con);
}

/**
 * 向GC发送数据
 */
function sendToGC($words){
	global $GCIp, $GCPort;
	
	$socket = socket_create(AF_INET, SOCK_STREAM, SOL_TCP);
	$con=socket_connect($socket, $GCIp, $GCPort);
	if(!$con){
		socket_close($socket);
		return;
	}

	socket_write($socket, $words."\n");
	socket_shutdown($socket);
	socket_close($socket);
}
	

/**
 *  接收POST数据
 */

$PostData = file_get_contents("php://input");

/**
 *  开发者服务器向MMarket 平台返回的状态说明
 *  $hRet:
	  		0		成功
			1		其他错误,未知错误
			2		网络异常（该错误指内部子系统之间调用出错）
			9010	繁忙
			9015	拒绝消息，服务器无法完成请求的服务
			9018	外部网元的网络错误
			4000	无效的MsgType 
			4003	无效的APPID
			4004	无效的PayCode
			4005	无效的MD5Sign
  */

if($PostData) {
	writeLog("received PostData", $PostData);
	$ArrayData = $MMarket->XmlToData($PostData);//xml数据转换为数组
	if(is_array($ArrayData)) {
		/**
		 * 验证签名信息
		 */
		foreach ($AppKey as $key=>$value) {
			$flag = $MMarket->ValidSign($ArrayData, $key);      
			if($flag == true) {
				//开发者进行订单数据处理,并返回处理结果给MMarket 平台
				
				//将成功的订单发给GC
				sendToGC($ArrayData["ExData"]);
				writeBilling($ArrayData["TradeID"], $value, "mmPaySucceed", $ArrayData["OrderID"]);
				
				$hRet = 0; //成功
				echo $MMarket->SyncAppOrderResp($hRet);//向M-Market平台返回结果
				exit;
			}
		}
		writeLog("invalid MD5Sign", $ArrayData["MD5Sign"]);
		$hRet = 4005; //无效的MD5Sign
		echo $MMarket->SyncAppOrderResp($hRet);//向M-Market平台返回结果
	}
}
	
?>