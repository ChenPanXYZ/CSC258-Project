module randomNumber(
    input reset_n,    
    input clock,      
    input load,
    input [1:0] seed,
	input enable, // enable to change the randomNumber
    output reg [1:0] randomNumber // We have three moles, so need 2-bit randomNumber.
);
	always@(posedge clock or negedge reset_n)
	begin
		if(!reset_n)
			randomNumber <= 2'b00;
		else if(load)
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

module display_controller(clock, game, turnoff, speed, seed, mole1, mole2, mole3);
	input clock;
	input game;
	input turnoff;
	input [27:0] speed;
	input [1:0] seed;
	output reg [0:0] mole1;
	output reg [0:0] mole2;
	output reg [0:0] mole3;
	
	reg refresh;
	wire [1:0] randomNumber;
	wire [27:0] myRateCounterOut;
	
	
	
	
	
	//assign refresh = ( (myRateCounterOut == 25'd00000000) || (forceRefresh == 1'b1) ) ? 1 : 0 ;
	
	always@(*)
	begin
		if(!game) begin
			mole1 <= 0;
			mole2 <= 0;
			mole3 <= 0;
			refresh <= 1;
		end
		else begin
			refresh <= (myRateCounterOut == 25'd00000000 || turnoff) ? 1 : 0;
			mole1 <= (randomNumber == 2'b00 && !turnoff && !refresh && game) ? 1 : 0;
			mole2 <= (randomNumber == 2'b01 && !turnoff && !refresh && game) ? 1 : 0;
			mole3 <= (randomNumber == 2'b10 && !turnoff && !refresh && game) ? 1 : 0;
		end
	end
	
	rateCounter myRateCounter(
		.d(speed),
		.clock(clock),
		.par_load(refresh),
		.q(myRateCounterOut)
	);
	
	randomNumber myRandomNumber(
		.reset_n(game), // reset if the game is not running.
		.clock(clock),
		.load(!game),
		.seed(seed),
		.enable(refresh),
		.randomNumber(randomNumber)
	);

endmodule;