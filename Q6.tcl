set ns [new Simulator]
set nf [open nam.out w]
$ns namtrace-all $nf
set tr [open Q6.tr w]
$ns trace-all $tr

proc finish {} {
	global ns nf tr
	$ns flush-trace
	close $tr
	close $nf
	exit 0
}

set topo [new Topography]
$topo load_flatgrid 750 750

$ns node-config -adhocRouting AODV \
	-llType LL \
	-macType Mac/802_11 \
	-ifqType Queue/DropTail \
	-channelType Channel/WirelessChannel \
	-propType Propagation/TwoRayGround
	-antType Antenna/OmniAntenna
	-ifqLen 50 \
	-phyType Phy/WirelessPhy \
	-topoInstance $topo
	-agentTrace ON \
	-routerTrace ON \
	-macTrace OFF \
	-movementTrace ON

set god_ [create-god $n]

set n 7
for {set i 0} {$i < $n} {incr i} {
	set n($i) [$ns node]
}

for {set i 0} {$i < $n} {incr i} {
	set X [expr rand()*750]
	set Y [expr rand()*750]
	set $n($i) X_ X
	set $n($i) Y_ Y
}

for {set i 0} {$i < $n} {incr i} {
	$ns initial_node_pos $n($i) 100
}

proc destination {} {
	global ns n
	set time 5.0
	set now [$ns now]
	for {set i 0} {$i < $n} {incr i} {
		set X [expr rand()*750]
		set Y [expr rand()*750]
		$ns at [expr $now + $time] "$n($i) setdest $X $Y 20.0"
	}
	$ns at [expr $now + $time] "destination"
}

set tcp [new Agent/TCP]
$ns attach-agent $tcp $n(1)
set ftp [new Application/FTP]
$ftp attach-agent $tcp
set sink [new Agent/TCPSink]
$ns attach-agent $sink $n(3)
$ns connect $sink $tcp

$ns at 1.0 "destination"
$ns at 1.5 "$ftp start"
$ns at 100 "$ftp stop"
$ns at 101 "finish"

$ns run