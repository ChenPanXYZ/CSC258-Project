vlib work

vlog -timescale 1ps/1ps display_controller.v

vsim -L altera_mf_ver display_controller

log {/*}
add wave {/*}

force {clock} 0
force {game} 0
force {turnoff} 0
force {speed} 0000000000000000000000000011
force {seed} 01
run 160ps

force {clock} 1
force {game} 0
force {turnoff} 0
force {speed} 0000000000000000000000000011
force {seed} 01
run 160ps


force {clock} 0
force {game} 1
force {turnoff} 0
force {speed} 0000000000000000000000000011
force {seed} 01
run 160ps

force {clock} 1
force {game} 1
force {turnoff} 0
force {speed} 0000000000000000000000000011
force {seed} 01
run 160ps
# by our pseudo random number generator, mole1 will be on.




force {clock} 0
force {game} 1
force {turnoff} 1
force {speed} 0000000000000000000000000011
force {seed} 01
run 160ps

force {clock} 1
force {game} 1
force {turnoff} 1
force {speed} 0000000000000000000000000011
force {seed} 01
run 160ps

#if the use pushes the right buttom - a turnoff signal is sent, so mole1 turns off and we enter another round.




force {clock} 0
force {game} 1
force {turnoff} 0
force {speed} 0000000000000000000000000011
force {seed} 01
run 160ps

force {clock} 1
force {game} 1
force {turnoff} 0
force {speed} 0000000000000000000000000011
force {seed} 01
run 160ps



force {clock} 0
force {game} 1
force {turnoff} 0
force {speed} 0000000000000000000000000011
force {seed} 01
run 160ps

force {clock} 1
force {game} 1
force {turnoff} 0
force {speed} 0000000000000000000000000011
force {seed} 01
run 160ps



force {clock} 0
force {game} 1
force {turnoff} 0
force {speed} 0000000000000000000000000011
force {seed} 01
run 160ps

force {clock} 1
force {game} 1
force {turnoff} 0
force {speed} 0000000000000000000000000011
force {seed} 01
run 160ps
#Automatically turn off.