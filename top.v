module randomNumber(  
    input clock,      
    input load,
	input enable, // enable to change the randomNumber
    output reg [7:0] randomNumber // We have three moles, so need 2-bit randomNumber.
);
	wire feedback;
	assign feedback = ~(randomNumber[7] ^ randomNumber[6]);
	
	always@(posedge load or posedge enable)
	begin
		if(load)
			randomNumber = 7'hFF;
		else if(enable)
			begin
			randomNumber = {randomNumber[6:0], feedback};
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

module display_controller(
	input clock,
	input game,
	input turnoff,
	input [27:0] speed,
	output reg mole1,
	output reg mole2,
	output reg mole3,
	output [7:0] RanNumber,
	output [27:0] myRateCounterOut,
	output reg refresh
);
	
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
				end
			mole1 = ((0<= RanNumber && RanNumber < 70) && !refresh && !(myRateCounterOut == 28'b0000000000000000000000000000) && game) ? 1 : 0;
			mole2 = ((70<= RanNumber && RanNumber < 180)  && !refresh && !(myRateCounterOut == 28'b0000000000000000000000000000) && game) ? 1 : 0;
			mole3 = ((180<= RanNumber && RanNumber <= 255) && !refresh && !(myRateCounterOut == 28'b0000000000000000000000000000) && game) ? 1 : 0;
		end
	end
	
	rateCounter myRateCounter(
		.clock(clock),
		.d(speed),
		.par_load(refresh),
		.q(myRateCounterOut)
	);
	
	randomNumber myRandomNumber(
		.clock(clock),
		.load(!game),
		.enable(refresh),
		.randomNumber(RanNumber)
	);

endmodule;


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
	always@(posedge clock or posedge button1 or posedge button2 or posedge button3) // when click the button, changed turnoff immediately
	begin
		if (!game) begin
			score = 0;
			turnoff = 0;
		end
		else begin
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
	end
	
endmodule;




module top(
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
	output [7:0] score // 8-bit, can store 255 points at most. Will need two 7-segment decoders.
);
	
	wire turnoffWire;
	wire [7:0] random;// This is for test only. Should be removed later.
	wire [27:0] myRateCounterOut;
	wire refresh;
	
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
endmodule;