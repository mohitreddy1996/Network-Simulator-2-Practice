 # Simulate an Ethernet LAN using n nodes and set multiple traffic nodes and plot congestion window for different source/destination

set ns [new Simulator]

set nf [open nam.out w]
set tr [open Q5.tr w]
$ns namtrace-all $nf
$ns trace-all $tr

set winfile0 [open WinFile w]
set winfile1 [open WinFile1 w]

proc finish {} {
	global ns nf tr
	$ns flush-trace
	close $nf
	close $tr

	exec xgraph winfile1 winfile0
	exit 0
}

proc Plotwindow {tcpSource file} {
	global ns
	set time 0.1
	set now [$ns now]
	set cwnd [$tcpSource set cwnd_]
	puts $file "$now $cwnd"
	$ns at [expr $now + $time] "Plotwindow $tcpSource $file"
}

for {set i 0} {$i < 6} {incr i} {
	set n($i) [$ns node]
}

$ns duplex-link $n(0) $n(1) 1Mb 10ms DropTail
$ns duplex-link $n(2) $n(1) 1Mb 10ms DropTail
$ns simplex-link $n(2) $n(3) 1Mb 40ms DropTail
$ns simplex-link $n(3) $n(2) 1Mb 40ms DropTail

$ns queue-limit $n(2) $n(3) 20

set ran_var [new RandomVariable/Uniform]
$ran_var set min_ 0
$ran_var set max_ 100

set lossmodel [new ErrorModel]
$lossmodel set drop-target [new Agent/Null]
$lossmodel set rate_ 10
$lossmodel ranvar $ran_var

$ns lossmodel $lossmodel $n(2) $n(3)

set tcp [new Agent/TCP]
$ns attach-agent $tcp $n(0)
$tcp set interval_ 0.005
$tcp set packetSize_ 1024
set ftp [new Application/FTP]
$ftp attach-agent $tcp
set sink [new Agent/TCPSink]
$ns attach-agent $sink $n(5)
$ns connect $sink $tcp

set udp [new Agent/UDP]
$ns attach-agent $udp $n(2)
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set interval_ 0.005
$cbr set packetSize_ 1024

set null0 [new Agent/Null]
$ns attach-agent $null0 $n(5)
$ns connect $udp $null0

$ns at 1.0 "$ftp start"
$ns at 1.0 "Plotwindow $tcp $winfile0"
$ns at 1.5 "$cbr start"
$ns at 1.5 "Plotwindow $cbr $winfile1"
$ns at 4.5 "$cbr stop"
$ns at 5.0 "$ftp stop"
$ns at 5.5 "finish"

$ns run
