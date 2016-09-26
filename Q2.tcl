#Simulate a four node point-to- point network with the links connected as follows: n0 – n2,
#n1 – n2 and n2 – n3. Apply TCP agent between n0-n3 and UDP between n1-n3. Apply
#relevant applications over TCP and UDP agents changing the parameter and determine the number of packets sent by TCP / UDP.


set ns [new Simulator]

set nf [open out.nam w]
set tr [open Q2.tr w]

$ns namtrace-all $nf
$ns namtrace-all $tr

proc finish {} {
	global ns nf tr
	close $nf
	close $tr
	$ns flush-trace
	exit 0
}

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

$ns duplex-link $n0 $n2 1Mb 10ms DropTail
$ns duplex-link $n1 $n2 1Mb 10ms DropTail
$ns duplex-link $n2 $n3 1.5Mb 10ms DropTail

set tcp0 [new Agent/TCP]
$ns attach-agent $tcp0 $n0

set ftp0 [new Application/FTP]
$ftp attach-agent $tcp0

set sink [new Agent/TCPSink]
$ns attach-agent $sink $n3
$ns connect $tcp0 $sink

set udp [new Agent/UDP]
$ns attach-agent $udp $n1
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
set null0 [new Agent/Null]
$ns attach-agent $null0 $n3

$ns connect $null0 $udp

$ns at 1.0 "$cbr start"
$ns at 1.2 "$ftp start"
$ns at 5.0 "$cbr stop"
$ns at 4.8 "$ftp stop"
$ns at 5.1 "finish"

$ns run
