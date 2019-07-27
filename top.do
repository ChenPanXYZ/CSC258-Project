vlib work

vlog -timescale 1ps/1ps top.v

vsim -L altera_mf_ver top

log {/*}
add wave {/*}
force {clock} 0
force {button1} 0
force {button2} 0
force {button3} 0
force {game} 0
force {speed} 28'd49999999
run 160ps
force {clock} 1
force {button1} 0
force {button2} 0
force {button3} 0
force {game} 0
force {speed} 28'd49999999
run 160ps


#Game Starts
force {clock} 0
force {button1} 0
force {button2} 0
force {button3} 0
force {game} 1
force {speed} 28'd49999999
run 160ps
force {clock} 1
force {button1} 0
force {button2} 0
force {button3} 0
force {game} 1
force {speed} 28'd49999999
run 160ps







force {clock} 0 0ps, 1 1ps -r 2ps
force {button2} 0 0ps, 1 5005ps  -c 5005ps

run 1000000ns