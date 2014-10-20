#!/bin/bash

# ϵͳ���,��¼cpu��memory��load average,�������涨��ֵʱ������֪ͨ����Ա

# *** config start ***

# ��ǰĿ¼·��
CWD=$(cd "$(dirname "$0")"; pwd)

# ��ǰ��������
HOST=$(hostname)

# ֪ͨ�����б�
NOTICE_EMAIL=$1

# cpu,memory,load average ��¼��һ�η���֪ͨ����ʱ��
CPU_REMARK='${CWD}/monitor_cpu.remark'
MEM_REMARK='${CWD}/monitor_mem.remark'
LOAD_REMARK='${CWD}/monitor_load.remark'

# ��֪ͨ���ʼ��ʱ��
REMARK_EXPIRE=3600
NOW=$(date +%s)

# *** config end ***


# *** function start ***

# ��ȡCPUռ��
function GetCpu() {
    cpufree=$(vmstat 1 5 |sed -n '3,$p' |awk '{x = x + $15} END {print x/5}' |awk -F. '{print $1}')
    cpuused=$((100 - $cpufree))
    echo $cpuused

    local remark
    remark=$(GetRemark ${CPU_REMARK})

    # ���CPUռ���Ƿ񳬹�90%
    if [ "$remark" = "" ] && [ "$cpuused" -gt 90 ]; then
        echo "Subject: ${HOST} CPU uses more than 90% $(date +%Y-%m-%d' '%H:%M:%S)" | sendmail ${NOTICE_EMAIL}
        echo "$(date +%s)" > "$CPU_REMARK"
    fi
}

# ��ȡ�ڴ�ʹ�����
function GetMem() {
    mem=$(free -m | sed -n '3,3p')
    used=$(echo $mem | awk -F ' ' '{print $3}')
    free=$(echo $mem | awk -F ' ' '{print $4}')
    total=$(($used + $free))
    limit=$(($total/10))
    echo "${total} ${used} ${free}"

    local remark
    remark=$(GetRemark ${MEM_REMARK})

    # ����ڴ�ռ���Ƿ񳬹�90%
    if [ "$remark" = "" ] && [ "$limit" -gt "$free" ]; then
        echo "Subject: ${HOST} Memory uses more than 90% $(date +%Y-%m-%d' '%H:%M:%S)" | sendmail ${NOTICE_EMAIL}
        echo "$(date +%s)" > "$MEM_REMARK"
    fi
}

# ��ȡload average
function GetLoad() {
    load=$(uptime | awk -F 'load average: ' '{print $2}')
    m1=$(echo $load | awk -F ', ' '{print $1}')
    m5=$(echo $load | awk -F ', ' '{print $2}')
    m15=$(echo $load | awk -F ', ' '{print $3}')
    echo "${m1} ${m5} ${m15}"

    m1u=$(echo $m1 | awk -F '.' '{print $1}')

    local remark
    remark=$(GetRemark ${LOAD_REMARK})

    # ����Ƿ����Ƿ���ѹ��
    if [ "$remark" = "" ] && [ "$m1u" -gt "2" ]; then
        echo "Subject: ${HOST} Load Average more than 2 $(date +%Y-%m-%d' '%H:%M:%S)" | sendmail ${NOTICE_EMAIL}
        echo "$(date +%s)" > "$LOAD_REMARK"
    fi
}

# ��ȡ��һ�η��͵���ʱ��
function GetRemark() {
    local remark

    if [ -f "$1" ] && [ -s "$1" ]; then
        remark=$(cat $1)

        if [ $(( $NOW - $remark )) -gt "$REMARK_EXPIRE" ]; then
            rm -f $1
            remark=""
        fi
    else
        remark=""
    fi

    echo $remark
}


# *** function end ***


cpuinfo=$(GetCpu)
meminfo=$(GetMem)
loadinfo=$(GetLoad)
timestamp=$(date "+%Y-%m-%d %H-%M-%S")

echo "${timestamp} cpu: ${cpuinfo}" >> "${CWD}/monitor.log"
echo "${timestamp} mem: ${meminfo}" >> "${CWD}/monitor.log"
echo "${timestamp} load: ${loadinfo}" >> "${CWD}/monitor.log"

if [ -r "${CWD}/pid" ]; then
	cat "${CWD}/pid" | while read i
	do
		ps -p $i > nul
		if [ $? = "1" ]; then
			sed -i "/$i/d" "${CWD}/pid"
			echo "Subject: ${HOST} Server Crashed !!!! $(date +%Y-%m-%d' '%H:%M:%S)" | sendmail ${NOTICE_EMAIL}
		fi
	done
fi

exit 0
