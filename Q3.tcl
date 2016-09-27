# Simulate the transmission of ping messages over a network topology consisting of 6
# nodes and find the number of packets dropped due to congestion.
set ns [new Simulator]
set nf [open out.name w]
set tr [open Q3.tr w]
$ns namtrace-all $nf
$ns trace-all $tr

proc finish {} {
	global ns nf tr
	$ns flush-trace
	close $nf
	close $tr
	exit 0
}

for {set i 0} {$i<7} {incr i} {
	set n($i) [$ns node]
}

for {set i 1} {$i<7} {incr i} {
	$ns duplex-link $n($i) $n(0) 1Mb 10ms DropTail
}

for {set i 1} {$i < 7} {incr i} {
	set p($i) [new Agent/Ping]
}

for {set i 1} {$i < 7} {incr i} {
	$ns attach-agent $n($i) $p($i)
}

$ns queue-limit $n(0) $n(4) 3
$ns queue-limit $n(0) $n(5) 2
$ns queue-limit $n(0) $n(6) 2

$ns connect $p(4) $p(1)
$ns connect $p(5) $p(2)
$ns connect $p(6) $p(3)

$ns at 1.0 "$p(1) send"
$ns at 2.0 "$p(2) send"
$ns at 3.0 "$p(3) send"
$ns at 4.0 "$p(4) send"
$ns at 5.0 "$p(5) send"
$ns at 6.0 "$p(6) send"

$ns at 7.0 "finish"

$ns run