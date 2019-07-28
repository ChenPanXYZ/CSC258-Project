module seven_segment_decoder(HEX, SW);
    input [3:0] SW;
    output [6:0] HEX;
	
	hex0 s0(
		.c0(SW[0]),
		.c1(SW[1]),
		.c2(SW[2]),
		.c3(SW[3]),
		.m(HEX[0])
		);	
	hex1 s1(
		.c0(SW[0]),
		.c1(SW[1]),
		.c2(SW[2]),
		.c3(SW[3]),
		.m(HEX[1])
		);	
	hex2 s2(
		.c0(SW[0]),
		.c1(SW[1]),
		.c2(SW[2]),
		.c3(SW[3]),
		.m(HEX[2])
		);	
	hex3 s3(
		.c0(SW[0]),
		.c1(SW[1]),
		.c2(SW[2]),
		.c3(SW[3]),
		.m(HEX[3])
		);
	hex4 s4(
		.c0(SW[0]),
		.c1(SW[1]),
		.c2(SW[2]),
		.c3(SW[3]),
		.m(HEX[4])
		);	
	hex5 s5(
		.c0(SW[0]),
		.c1(SW[1]),
		.c2(SW[2]),
		.c3(SW[3]),
		.m(HEX[5])
		);
	hex6 s6(
		.c0(SW[0]),
		.c1(SW[1]),
		.c2(SW[2]),
		.c3(SW[3]),
		.m(HEX[6])
		);	
endmodule

module hex0(c0, c1, c2, c3, m);
    input c0;
    input c1;
    input c2;
	input c3;
    output m;
	
	assign m = (~c3 & ~c2 & ~c1 & c0) | (~c3 & c2 & ~c1 & ~c0) | (c3 & c2 & ~c1 & c0) | (c3 & ~c2 & c1 & c0);

endmodule


module hex1(c0, c1, c2, c3, m);
    input c0;
    input c1;
    input c2;
	input c3;
    output m;
	
	assign m = (c3 & c2 & c1) | (c3 & c2 & ~c1 & ~c0) | (~c3 & c2 & ~c1 & c0) | (c3 & ~c2 & c1 & c0) | (~c3 & c2 & c1 & ~c0);

endmodule

module hex2(c0, c1, c2, c3, m);
    input c0;
    input c1;
    input c2;
	input c3;
    output m;
	
	assign m = (c3 & c2 & c1) | (c3 & c2 & ~c1 & ~c0) | (~c3 & ~c2 & c1 & ~c0);

endmodule

module hex3(c0, c1, c2, c3, m);
    input c0;
    input c1;
    input c2;
	input c3;
    output m;
	
	assign m = (~c2 & ~c1 & c0) | (c2 & c1 & c0) | (~c3 & c2 & ~c1 & ~c0) | (c3 & ~c2 & c1 & ~c0);

endmodule

module hex4(c0, c1, c2, c3, m);
    input c0;
    input c1;
    input c2;
	input c3;
    output m;
	
	assign m = (~c3 & c0) | (~c3 & c2 & ~c1 & ~c0) | (c3 & ~c2 & ~c1 & c0);

endmodule

module hex5(c0, c1, c2, c3, m);
    input c0;
    input c1;
    input c2;
	input c3;
    output m;
	
	assign m = (~c3 & c1 & c0) | (~c3 & ~c2 & ~c1 & c0) | (c3 & c2 & ~c1 & c0) | (~c3 & ~c2 & c1 & ~c0);

endmodule

module hex6(c0, c1, c2, c3, m);
    input c0;
    input c1;
    input c2;
	input c3;
    output m;
	
	assign m = (~c3 & ~c2 & ~c1) | (c3 & c2 & ~c1 & ~c0) | (~c3 & c2 & c1 & c0);

endmodule



module randomNumber(  
    input clock,      
    input load,
	input enable, // enable to change the randomNumber
    output reg [2:0] randomNumber // We have three moles, so need 2-bit randomNumber.
);
	wire feedback;
	assign feedback = ~(randomNumber[2] ^ randomNumber[1]);
	
	always@(posedge load or posedge enable)
	begin
		if(load)
			randomNumber = 000;
		else if(enable)
			begin
			randomNumber = {randomNumber[1:0], feedback};
			end
	end
endmodule

module rateCounter(
	input clock,
	input [27:0] d,
	input par_load,
	output reg [27:0] q
);
	always @(posedge clock or posedge par_load)
	begin
		if(par_load == 1'b1)
			q <= d;
		else if (q == 28'd000000000)
			q <= d;
		else
			q <= q - 28'd000000001;
	end
endmodule

/* 
module rateCounterForWait(
	input clock,
	input [27:0] d,
	input par_load,
	output reg [27:0] q
);
	always @(posedge par_load)
	begin
		if(par_load == 1'b1)
			q <= d;
		else if (q == 28'd000000000)
			q <= q;
		else
			q <= q - 28'd000000001;
	end
endmodule */



module display_controller(
	input clock,
	input game,
	input turnoff,
	input [27:0] speed,
	output reg mole1,
	output reg mole2,
	output reg mole3
);
	reg waitFinish;
	wire [2:0] RanNumber;
	wire [27:0] myRateCounterOut;
	reg refresh;
	
	always@(posedge clock or posedge turnoff or negedge turnoff)
	begin
		if(!game) begin
			mole1 = 0;
			mole2 = 0;
			mole3 = 0;
			refresh = 1;
		end
		else begin
			refresh = turnoff;
			if(refresh == 2'b0) 
				begin
					refresh = (myRateCounterOut == 28'b0000000000000000000000000000) ? 1 : 0;
					waitFinish = (myRateCounterOut < (speed)) ? 1:0;
				end
			mole1 = ((RanNumber == 1  || RanNumber == 5) && !refresh && !(myRateCounterOut == 28'b0000000000000000000000000000) && game && waitFinish) ? 1 : 0;
			mole2 = ((RanNumber == 0 || RanNumber == 2 || RanNumber == 7)  && !refresh && !(myRateCounterOut == 28'b0000000000000000000000000000) && game && waitFinish) ? 1 : 0;
			mole3 = ((RanNumber == 3 || RanNumber == 4 || RanNumber == 6) && !refresh && !(myRateCounterOut == 28'b0000000000000000000000000000) && game && waitFinish) ? 1 : 0;
		end
	end
	
	rateCounter myRateCounter(
		.clock(clock),
		.d(speed + 28'd149999999), //3 Seconds between the two rounds.
		.par_load(refresh),
		.q(myRateCounterOut)
	);
	
	randomNumber myRandomNumber(
		.clock(clock),
		.load(!game),
		.enable(refresh),
		.randomNumber(RanNumber)
	);

endmodule


module player(
	input clock,
	input button1, 
	input button2, 
	input button3,
	input mole1, 
	input mole2, 
	input mole3,
	input game,
	output reg turnoff,
	output reg [7:0] score
);

	always@(posedge clock) // when click the button, changed turnoff immediately
	begin
		if (!game) begin
			score = 0;
			turnoff = 0;
		end
	end
	
	always@(posedge button1 or posedge button2 or posedge button3) // when click the button, changed turnoff immediately
	begin
		turnoff = (game && ((mole1 && button1) || (mole2 && button2) || (mole3 && button3))) ? 1 : 0;
		if(turnoff) begin
			score = score + 1;
		end
		else begin
			if((button1 || button2 || button3) && (mole1 || mole2 || mole3) && score != 0) begin
				score = score - 1;
			end
		end
	end
	
endmodule




/* module top(
//Note that speed is designed to be provided by the FSM (level controller). Now for test purpose, we give a speed manually.
	input clock,
	input button1, 
	input button2, 
	input button3,
	input game,
	input [27:0] speed,
	output mole1,
	output mole2,
	output mole3,
	output [6:0] HEX0,
	output [6:0] HEX1
);
	
	wire turnoffWire;
	wire [2:0] random;// This is for test only. Should be removed later.
	wire [27:0] myRateCounterOut;
	wire refresh;
	wire [7:0] score;
	
	player p(
		.clock(clock),
		.button1(button1),
		.button2(button2),
		.button3(button3),
		.mole1(mole1),
		.mole2(mole2),
		.mole3(mole3),
		.game(game),
		.turnoff(turnoffWire),
		.score(score)
	);

	display_controller d(
		.clock(clock),
		.game(game),
		.turnoff(turnoffWire),
		.speed(speed),
		.mole1(mole1),
		.mole2(mole2),
		.mole3(mole3),
		.RanNumber(random),
		.myRateCounterOut(myRateCounterOut),
		.refresh(refresh)
	);
	
	seven_segment_decoder H0(
		.HEX(HEX0),
		.SW(score[3:0])
	);
	seven_segment_decoder H1(
		.HEX(HEX1),
		.SW(score[7:4])
	);
endmodule; */


module top(
	input clock,
	input button1, 
	input button2, 
	input button3,
	input game,
	output mole1,
	output mole2,
	output mole3,
	output [6:0] HEX0,
	output [6:0] HEX1
);
	
	wire turnoffWire;
	wire [7:0] score;
	
	player p(
		.clock(clock),
		.button1(button1),
		.button2(button2),
		.button3(button3),
		.mole1(mole1),
		.mole2(mole2),
		.mole3(mole3),
		.game(game),
		.turnoff(turnoffWire),
		.score(score)
	);

	display_controller d(
		.clock(clock),
		.game(game),
		.turnoff(turnoffWire),
		.speed(28'd099999999),
		.mole1(mole1),
		.mole2(mole2),
		.mole3(mole3)
	);
	
	seven_segment_decoder H0(
		.HEX(HEX0),
		.SW(score[3:0])
	);
	seven_segment_decoder H1(
		.HEX(HEX1),
		.SW(score[7:4])
	);
endmodule


//Uncomment this block to test on the board with SW and LEDR.
/* module top(
	input CLOCK_50,
	input [2:0] KEY, 
	input [0:0] SW,
	output [2:0] LEDR,
	output [6:0] HEX0,
	output [6:0] HEX1
);
	
	wire turnoffWire;
	wire [7:0] score;
	
	player p(
		.clock(CLOCK_50),
		.button1(!KEY[0]),
		.button2(!KEY[1]),
		.button3(![KEY[2]]),
		.mole1(mole1),
		.mole2(mole2),
		.mole3(mole3),
		.game(SW[0]),
		.turnoff(turnoffWire),
		.score(score)
	);

	display_controller d(
		.clock(CLOCK_50),
		.game(SW[0]),
		.turnoff(turnoffWire),
		.speed(28'd099999999),
		.mole1(LEDR[0]),
		.mole2(LEDR[1],
		.mole3(LEDR[2])
	);
	
	seven_segment_decoder H0(
		.HEX(HEX0),
		.SW(score[3:0])
	);
	seven_segment_decoder H1(
		.HEX(HEX1),
		.SW(score[7:4])
	);
endmodule; */