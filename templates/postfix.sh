#!/bin/bash

MAILLOG=postfix
DAT1=/tmp/zabbix-postfix-offset.dat
DAT2=$(mktemp)
PFLOGSUMM=/usr/sbin/pflogsumm
ZABBIX_CONF=/etc/zabbix/zabbix_agentd.conf
DEBUG=0

function zsend {
  key="postfix[`echo "$1" | tr ' -' '_' | tr '[A-Z]' '[a-z]' | tr -cd [a-z_]`]"
  value=`grep -m 1 "$1" $DAT2 | awk '{print $1}' | awk '/k|m/{p = /k/?1:2}{printf "%d\n", int($1) * 1024 ^ p}'`

  [ ${DEBUG} -ne 0 ] && echo "Send key \"${key}\" with value \"${value}\"" >&2
  /usr/bin/zabbix_sender -c $ZABBIX_CONF -k "${key}" -o "${value}" 2>&1 >/dev/null
}

/usr/bin/journalctl --since "`cat $DAT1`" -a -u $MAILLOG | $PFLOGSUMM -h 0 -u 0 --bounce_detail=0 --deferral_detail=0 --reject_detail=0 --no_no_msg_size --smtpd_warning_detail=0 > $DAT2
/usr/bin/date +%Y-%m-%d\ %H:%M:%S > $DAT1

zsend received
zsend delivered
zsend forwarded
zsend deferred
zsend bounced
zsend rejected
zsend held
zsend discarded
zsend "reject warnings"
zsend "bytes received"
zsend "bytes delivered"
zsend senders
zsend recipients

rm $DAT2

