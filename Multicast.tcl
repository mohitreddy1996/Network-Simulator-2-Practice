# simulator object
set ns [new Simulator]

set nf [open out.nam w]
$ns namtrace-all $nf

proc finish {} \
{
	global ns nf
	$ns flush-trace
	close $nf
	exit 0
}

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

$ns duplex-link $n0 $n1 1.5Mb 10ms DropTail
$ns duplex-link $n1 $n2 1.5Mb 10ms DropTail
$ns duplex-link $n1 $n3 1.5Mb 10ms DropTail

set mproto DM
set mrthandle [$ns mrtproto $mproto {}]

set group0 [Node allocaddr]
set group1 [Node allocaddr]

set udp0[new Agent/UDP]
$ns attach-agent $n1 $udp0
$udp0 set dst_addr_ $group0
$udp0 set dst_port_ 0

set cbr0 [new Application/Traffic/CBR]
$cbr0 attach-agent $udp0

set udp1[new Agent/UDP]
$ns attach-agent $udp1 $n3
$udp1 set dst_addr_ $group1
$udp1 set dst_port_ 0

set cbr1[new Traffic/Application/CBR]
$cbr1 attach-agent $udp1

# set a receiver as a loss monitor 
set rcvr [new Agent/LossMonitor]
$ns attach-agent $n2 $rcvr

$ns at 1.2 "$n2 join-group $rcvr $group1"
$ns at 1.25 "$n2 leave-group $rcvr $group1"
$ns at 1.3 "$n2 join-group $rcvr $group1"
$ns at 1.35 "$n2 join-group $rcvr $group0"

$ns at 1.0 "$cbr0 start"
$ns at 1.1 "$cbr1 start"

$ns at 2.0 "finish"

$ns run
