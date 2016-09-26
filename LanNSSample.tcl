# simulator object.
set ns[new Simulator]

$ns set color 1 Red
$ns set color 2 Blue

set nf [open out.nam w]
$ns namtrace-all $nf

proc finish {} {
	global ns nf
	$ns flush-trace
	close $nf
 	exit 0
}

for {set i 0} {$i<7} {incr i} {
	set n($i) [$ns node]
}

$ns duplex-link $n(0) $n(2) 1Mb 10ms DropTail
$ns duplex-link $(1) $n(2) 1Mb 10ms DropTail
$ns simplex-link $n(2) $n(3) 0.3Mb 100ms DropTail
$ns simplex-link $n(3) $n(2) 0.3Mb 100ms DropTail

set lan [$ns newLan "$n(3) $n(4) $n(5) $n(6)" 0.5Mb 40ms LL Queue/DropTail MAC/802_3 Channel]

set tcp[new Agent/TCP]

set sink[new Agent/TCPSink]
$ns attach-agent $sink $n(4)

$ns attach-agent $n(0) $tcp
$tcp set window_ 8000
$tcp set packet_size_ 552

set ftp[new Application/FTP]
$ftp attach-agent $tcp

$ns connect $sink $tcp


#setup UDP connection
set udp[new Agent/UDP]
$ns attach-agent $udp $n(1)
set null[new Agent/Null]

$ns attach-agent $null $n(5)

set cbr[new Application/Traffic/CBR]
$cbr attach-agent $udp
$udp set rate_ 0.1MB
$udp set packet_size_ 1000

$ns connect $null $udp

$ns at 0.1 "$cbr start"
$ns at 1.0 "$ftp start"
$ns at 3.5 "$ftp stop"
$ns at 4.0 "$cbr stop"
$ns at 5.0 "finish"

$ns run
