//module display_controller(clock, game, turnoff, speed, seed, mole1, mole2, mole3);
module player(button1, button2, button3, mole1, mole2, mole3, clock, game, turnoff);
	input button1, button2, button3;
	input mole1, mole2, mole3;
	input clock;
	input game;
	output reg turnoff;
	always@(posedge clock)
	begin
		turnoff <= (game && ((mole1 && button1) || (mole2 && button2) || (mole3 && button3))) ? 1 : 0;
	end
	
endmodule;