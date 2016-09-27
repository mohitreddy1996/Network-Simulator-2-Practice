# Simulate an Ethernet LAN using n nodes (6-10), change error rate and data rate and
# compare throughput.

set ns [new Simulator]

set nf [open nam.out w]
set tr [open Q4.tr w]

$ns namtrace-all $nf
$ns trace-all $tr

proc finish {} \
{
	global ns nf tr
	$ns flush-trace
	close $nf
	close $tr
	exit 0
}

for {set i 0} {$i < 6} {incr i} {
	set n($i) [$ns node]
}

$ns duplex-link $n(0) $n(2) 2Mb 10ms DropTail
$ns duplex-link $n(1) $n(2) 2Mb 10ms DropTail
$ns simplex-link $n(2) $n(3) 0.3Mb 10ms DropTail
$ns simplex-link $n(3) $n(2) 0.3Mb 10ms DropTail

set lan [$ns newLan "$n(3) $n(4) $n(5)" 0.5Mb 40ms LL Queue/DropTail MAC/802_3 Channel]

$ns queue-limit $n(2) $n(3) 10

# loss module between n2 and n3.
set loss_rand_var [new RandomVariable/Uniform]
$loss_rand_var set min_ 0
$loss_rand_var set max_ 100

set loss_module [new ErrorModel]
$loss_module drop-target [new Agent/Null]
$loss_module set rate_ 10
$loss_module ranvar $loss_rand_var

# data tranfer.
set tcp [new Agent/TCP]
$ns attach-agent $tcp $n(0)
$tcp set window_ 8000
$tcp set packetSize_ 1024
set sink [new Agent/TCPSink]
$ns attach-agent $sink $n(5)
$ns connect $tcp $sink

set ftp [new Application/FTP]
$ftp attach-agent $tcp

set udp [new Agent/UDP]
$ns attach-agent $udp $n(1)
set cbr [new Application/Traffic/CBR]
$cbr set interval_ 0.005
$cbr set packetSize_ 1024
$cbr attach-agent $udp
set null0 [new Agent/Null]
$ns attach-agent $null0 $n(5)
$ns connect $null0 $udp

$ns at 1.0 "$cbr start"
$ns at 1.2 "$ftp start"
$ns at 125.0 "$cbr stop"
$ns at 125.2 "$ftp stop"
$ns at 125.3 "finish"

$ns run


