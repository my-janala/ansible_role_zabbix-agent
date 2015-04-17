#!/usr/bin/perl
$ZABBIX_SERVER='192.168.100.8';
$MYHOSTNAME='openfiler';
$SENDER=`which zabbix_sender`;
chomp($SENDER);
$KEY='mdraid.status';
 
if (!$MYHOSTNAME || !$ZABBIX_SERVER || !$KEY || ! -x $SENDER) {
exit;
}
 
if ($ARGV[0] =~ /(Rebuild)(\d+)/) {
$ARGV[0] = $1;
$ARGV[2] = $2;
} elsif (!$ARGV[2]) {
$ARGV[2] = 'x';
}
 
my @result = `$SENDER -z '$ZABBIX_SERVER' -k $KEY."$ARGV[0]"["$ARGV[1]"] -o "$ARGV[2]" -s '$MYHOSTNAME'`;
 
#print @result;
 
exit 0;
