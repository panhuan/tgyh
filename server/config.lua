
local function shell (c)
	local h = io.popen (c)
	local o
	if h then
		o = h:read ("*a")
		h:close ()
	end
	return o
end

local ostype = os.getenv("OS") or shell("echo $OSTYPE")

package.path = "libs/?.lua;shared/?.lua;../base/?.lua;./?.lua;"
if ostype:find("Windows") then
	package.cpath = "clibs/win/?.dll;"
elseif ostype:find("linux") then
	package.cpath = "clibs/linux/?.so;"
end

RedisConfig = {
	ip = "10.132.30.128",
	port = 6379,
}

WSConfig = {
	[1] = {
		ip = "121.199.22.101",
		port = 16801,
		perfLog = "ws_perf.log",
		span = 0.001,
		payUrl = "http://121.199.22.101:8240",
	}
}

GSConfig = {
	[1] = {
		ip = "121.199.22.101",
		port = 26801,
		perfLog = "gs1_perf.log",
		span = 0.001,
	},
	[2] = {
		ip = "121.199.22.101",
		port = 26802,
		perfLog = "gs2_perf.log",
		span = 0.001,
	},
	[3] = {
		ip = "121.199.22.101",
		port = 26803,
		perfLog = "gs3_perf.log",
		span = 0.001,
	},
	[4] = {
		ip = "121.199.22.101",
		port = 26804,
		perfLog = "gs4_perf.log",
		span = 0.001,
	},
}

GCConfig = {
	ip = "121.199.22.101",
	port = 36801,
	perfLog = "gc_perf.log",
	span = 0.001,
}

LSConfig = {
	[1] = {
		ip = "121.40.69.141",
		port = 46801,
		perfLog = "ls1_perf.log",
		span = 0.001,
	},
	[2] = {
		ip = "121.40.69.141",
		port = 46802,
		perfLog = "ls2_perf.log",
		span = 0.001,
	},
	[3] = {
		ip = "121.40.69.141",
		port = 46803,
		perfLog = "ls3_perf.log",
		span = 0.001,
	},
	[4] = {
		ip = "121.40.69.141",
		port = 46804,
		perfLog = "ls4_perf.log",
		span = 0.001,
	},
}

DBConfig = {
	source = "kaixin",
	user = "kaixinol",
	pwd = "kaixinolpass",
	ip = "10.146.69.153",
	port = 3306,
}

LogDBConfig = {
	source = "kaixin_log",
	user = "kaixinol",
	pwd = "kaixinolpass",
	ip = "10.146.69.153",
	port = 3306,
}

SdkGateConfig = {
	ip = "127.0.0.1",
	port = 8001,
}

SdkBillingConfig = {
	ip = "127.0.0.1",
	port = 8002,
}

WebServerConfig = {
	ip = "127.0.0.1",
	port = 8003,
}

--360 pid=8
PLATFORM_ID = 8
pcall(dofile, "config.local")