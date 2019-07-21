module randomNumber(  
    input clock,      
    input load,
    input [1:0] seed,
	input enable, // enable to change the randomNumber
    output reg [1:0] randomNumber // We have three moles, so need 2-bit randomNumber.
);
	always@(posedge clock)
	begin
		if(load)
			randomNumber <= seed;
		else if(enable)
			begin
				randomNumber[0] <= randomNumber[1];
				randomNumber[1] <= randomNumber[0] ^ randomNumber[1];
			end
	end
endmodule

module rateCounter(d, clock, par_load, q);
	input [27:0] d;
	input clock;
	input par_load;
	output reg [27:0] q;
	always @(posedge clock)
	begin
		if(par_load == 1'b1)
			q <= d;
		else if (q == 28'd000000000)
			q <= d;
		else
			q <= q - 28'd000000001;
	end
endmodule

module display_controller(clock, game, turnoff, speed, seed, mole1, mole2, mole3, RanNumber);
	input clock;
	input game;
	input turnoff;
	input [27:0] speed;
	input [1:0] seed;
	output reg [0:0] mole1;
	output reg [0:0] mole2;
	output reg [0:0] mole3;
	output [1:0] RanNumber;
	
	reg refresh;
	//wire [1:0] RanNumber;
	wire [27:0] myRateCounterOut;
	//assign refresh = ( (myRateCounterOut == 25'd00000000) || (forceRefresh == 1'b1) ) ? 1 : 0 ;
	
	always@(posedge clock)
	begin
		if(!game) begin
			mole1 <= 0;
			mole2 <= 0;
			mole3 <= 0;
			refresh <= 1;
		end
		else begin
			refresh <= turnoff;
			if(refresh == 2'b0) begin
				refresh <= (myRateCounterOut == 28'b0000000000000000000000000000) ? 1 : 0;
			end
			
			mole1 <= (RanNumber == 2'b00 && !turnoff && !(myRateCounterOut == 25'b0000000000000000000000000000) && game) ? 1 : 0;
			mole2 <= (RanNumber == 2'b01 && !turnoff && !(myRateCounterOut == 25'b0000000000000000000000000000) && game) ? 1 : 0;
			mole3 <= (RanNumber == 2'b10 && !turnoff && !(myRateCounterOut == 25'b0000000000000000000000000000) && game) ? 1 : 0;
		end
	end
	
	rateCounter myRateCounter(
		.d(speed),
		.clock(clock),
		.par_load(refresh),
		.q(myRateCounterOut)
	);
	
	randomNumber myRandomNumber(
		//.reset_n(game), // reset if the game is not running.
		.clock(clock),
		.load(!game),
		.seed(seed),
		.enable(refresh),
		.randomNumber(RanNumber)
	);

endmodule;


//module display_controller(clock, game, turnoff, speed, seed, mole1, mole2, mole3);
module player(button1, button2, button3, mole1, mole2, mole3, clock, game, turnoff, score);
	input button1, button2, button3;
	input mole1, mole2, mole3;
	input clock;
	input game;
	output reg turnoff;
	output reg score;
	always@(posedge clock)
	begin
		if (!game) begin
			score <= 0;
			turnoff <= 0;
		end
		else begin
			turnoff <= (game && ((mole1 && button1) || (mole2 && button2) || (mole3 && button3))) ? 1 : 0;
			score <= (turnoff) ? (score+1) : score;
		end
	end
	
endmodule;




module top(clock, button1, button2, button3, game, seed, speed, score);
//Note that speed is designed to be provided by the FSM (level controller). Now for test purpose, we give a speed manually.
	input clock;
	input button1, button2, button3;
	input game;
	input [1:0] seed;
	input [27:0] speed;
	output score;
	
	wire mole1Wire, mole2Wire, mole3Wire;
	wire turnoffWire;
	wire [1:0] random;
	

	display_controller d(
		.clock(clock),
		.game(game),
		.turnoff(turnoffWire),
		.speed(speed),
		.seed(seed),
		.mole1(mole1Wire),
		.mole2(mole2Wire),
		.mole3(mole3Wire),
		.RanNumber(random)
	);
	
	player p(
		.button1(button1),
		.button2(button2),
		.button3(button3),
		.mole1(mole1Wire),
		.mole2(mole2Wire),
		.mole3(mole3Wire),
		.clock(clock),
		.game(game),
		.turnoff(turnoffWire),
		.score(score)
	);
endmodule;