vlib work

vlog -timescale 1ps/1ps top.v

vsim -L altera_mf_ver top
# 28'd049999999



log {/*}
add wave {/*}
force {clock} 0
force {button1} 0
force {button2} 0
force {button3} 0
force {game} 0
run 160ps
force {clock} 1
force {button1} 0
force {button2} 0
force {button3} 0
force {game} 0
run 160ps


#Game Starts
force {clock} 0
force {button1} 0
force {button2} 0
force {button3} 0
force {game} 1
run 160ps
force {clock} 1
force {button1} 0
force {button2} 0
force {button3} 0
force {game} 1
run 160ps







force {clock} 0 0ps, 1 1ps -r 2ps

run 1000000ns