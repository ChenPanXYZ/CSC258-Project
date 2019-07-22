vlib work

vlog -timescale 1ps/1ps player.v

vsim -L altera_mf_ver player

log {/*}
add wave {/*}

force {clock} 0
force {button1} 0
force {button2} 0
force {button3} 0
force {mole1} 1
force {mole2} 0
force {mole3} 0
run 160ps
force {clock} 1
force {button1} 0
force {button2} 0
force {button3} 0
force {mole1} 1
force {mole2} 0
force {mole3} 0
run 160ps


force {clock} 0
force {button1} 0
force {button2} 1
force {button3} 0
force {mole1} 1
force {mole2} 0
force {mole3} 0
force {game} 0
run 160ps
force {clock} 1
force {button1} 0
force {button2} 1
force {button3} 0
force {mole1} 1
force {mole2} 0
force {mole3} 0
run 160ps


force {clock} 0
force {button1} 1
force {button2} 0
force {button3} 0
force {game} 1
force {mole1} 1
force {mole2} 0
force {mole3} 0
run 160ps
force {clock} 1
force {button1} 1
force {button2} 0
force {button3} 0
force {mole1} 1
force {mole2} 0
force {mole3} 0
run 160ps