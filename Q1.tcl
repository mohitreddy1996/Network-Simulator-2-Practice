#Simulate a three nodes point – to – point network with duplex links between them.
#Set the queue size and vary the bandwidth and find the number of packets dropped.

# set simulator object.

set ns [new Simulator]
set nf [open out.nam w]
set tr [open q1.tr w]

$ns namtrace-all $nf
$ns namtrace-all $tr

proc finish {} \
{
	global ns nf tr
	$ns flush-trace
	close $nf
	close $tr
	exit 0
}

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]

$ns duplex-link $n0 $n1 1Mb 10ms DropTail
$ns duplex-link $n1 $n2 1Mb 10ms DropTail

set udp [new Agent/UDP]
$ns attach-agent $n0 $udp

set cbr [new Application/Traffic/CBR]
$cbr set interval_ 0.005
$cbr set packetSize_ 1000
$cbr attach-agent $udp

set null0 [new Agent/Null]
$ns attach-agent $null0 $n2

$ns connect $udp $null0

$ns at 0.2 "$cbr start"
$ns at 4.2 "$cbr stop"
$ns at 5.0 "finish"

$ns run