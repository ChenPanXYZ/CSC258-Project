// module paint
	// (
		// CLOCK_50,						//	On Board 50 MHz
		// coord,
		// mole,
		// reset,
		// VGA_CLK,   						//	VGA Clock
		// VGA_HS,							//	VGA H_SYNC
		// VGA_VS,							//	VGA V_SYNC
		// VGA_BLANK_N,						//	VGA BLANK
		// VGA_SYNC_N,						//	VGA SYNC
		// VGA_R,   						//	VGA Red[9:0]
		// VGA_G,	 						//	VGA Green[9:0]
		// VGA_B   						//	VGA Blue[9:0]
	// );

	// input			CLOCK_50;				//	50 MHz
	// input [1:0] coord;
	// input mole;
	// input reset;
	// output			VGA_CLK;   				//	VGA Clock
	// output			VGA_HS;					//	VGA H_SYNC
	// output			VGA_VS;					//	VGA V_SYNC
	// output			VGA_BLANK_N;				//	VGA BLANK
	// output			VGA_SYNC_N;				//	VGA SYNC
	// output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	// output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	// output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	// wire resetn;
	
	// height of 33 pixels down from top left
	// wire [6:0] y = 6'b100001;
	// wire writeEn;
	
	
	// reg [5:0] x;
   // always @(*)
   // begin
       // case(coord)
           // 2'b00: x = 6'b000001;//x set to 1
           // 2'b01: x = 6'b001001;//x set to 3
           // 2'b10: x = 6'b010001;//x set to 5
           // default: x = 6'b000001;
       // endcase
   // end
	 
	// reg [2:0] colour;
   // always @(*)
   // begin
       // case(mole)
           // 1'b0: colour = 3'b000;//set colour of block to black
           // default: colour = 3'b100;
       // endcase
   // end

	// vga_adapter VGA(
			// .resetn(reset),
			// .clock(CLOCK_50),
			// .colour(colour),
			// .x(x),
			// .y(y),
			// .plot(1),
			// .VGA_R(VGA_R),
			// .VGA_G(VGA_G),
			// .VGA_B(VGA_B),
			// .VGA_HS(VGA_HS),
			// .VGA_VS(VGA_VS),
			// .VGA_BLANK(VGA_BLANK_N),
			// .VGA_SYNC(VGA_SYNC_N),
			// .VGA_CLK(VGA_CLK));
		// defparam VGA.RESOLUTION = "160x120";
		// defparam VGA.MONOCHROME = "FALSE";
		// defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		// defparam VGA.BACKGROUND_IMAGE = "black.mif";
		
// endmodule

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
	input [29:0] d,
	input par_load,
	output reg [29:0] q
);
	always @(posedge clock or posedge par_load)
	begin
		if(par_load == 1'b1)
			q <= d;
		else if (q == 30'd000000000)
			q <= d;
		else
			q <= q - 30'd000000001;
	end
endmodule


module display_controller(
	input clock,
	input game,
	input turnoff,
	input [29:0] speed,
	output reg mole1,
	output reg mole2,
	output reg mole3
);
	reg waitFinish;
	wire [2:0] RanNumber;
	wire [29:0] myRateCounterOut;
	reg refresh;
	
	always@(posedge clock or posedge turnoff)
	begin
		if(turnoff) begin
			refresh = 1;
			mole1 = 0;
			mole2 = 0;
			mole3 = 0;
		end
		
		else if (!game) begin
			refresh = 1;
			mole1 = 0;
			mole2 = 0;
			mole3 = 0;
		end
		
		else begin
			refresh = (myRateCounterOut == 30'b0000000000000000000000000000) ? 1 : 0;
			waitFinish = (myRateCounterOut < (speed)) ? 1:0;
			mole1 = ((RanNumber == 1  || RanNumber == 5) && !refresh && !(myRateCounterOut == 30'b0000000000000000000000000000) && game && waitFinish) ? 1 : 0;
			mole2 = ((RanNumber == 0 || RanNumber == 2 || RanNumber == 7) && !refresh && !(myRateCounterOut == 30'b0000000000000000000000000000) && game && waitFinish) ? 1 : 0;
			mole3 = ((RanNumber == 3 || RanNumber == 4 || RanNumber == 6) && !refresh && !(myRateCounterOut == 30'b0000000000000000000000000000) && game && waitFinish) ? 1 : 0;
		end
		
	end
	
	rateCounter myRateCounter(
		.clock(clock),
		.d((speed + 30'd149999999)), //3 d149999999 Seconds between the two rounds.
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
	reg [7:0] scoreWire;
	reg turnoffWire;
	
	reg oldButton1, oldButton2, oldButton3;
	
	always@(posedge clock or posedge button1 or posedge button2 or posedge button3) // when click the button, changed turnoff immediately
	begin
		if (button1) 
			begin
				turnoff = (game && mole1) ? 1 : 0;
				score = (game && mole1) ? score + 1 : score;
				//score = (game && !mole1 && (mole2 || mole3) && !oldButton1 && (score !=0)) ? score - 1 : score;
			end
		else if (button2)
			begin
				turnoff = (game && mole2 && button2) ? 1 : 0;
				score = (game && mole2 && button2) ? score + 1 : score;
				//score = (game && !mole2 && (mole1 || mole3) && !oldButton2 && (score !=0)) ? score - 1 : score;
			end
		else if (button3)
			begin
				turnoff = (game && mole3 && button3) ? 1 : 0;
				score = (game && mole3 && button3) ? score + 1 : score;
				//score = (game && !mole3 && (mole1 || mole2) && !oldButton3 && (score !=0)) ? score - 1 : score;
			end
		else if(!game)
			begin
				turnoff = 0;
				score = 0;
			end
			oldButton1 <= button1;
			oldButton2 <= button2;
			oldButton3 <= button3;
	end
	
endmodule

module levelController(
	input clock,
	input game,
	input [7:0] score,
	output reg [29:0] speed
);
//A finite state machine that controls the difficulty of the game.
	always@(negedge clock) //I don't know why it is negedge but it seems correct in the simulation...
	begin
		if(!game)
			begin
				speed <= 30'd199999999; //4 Seconds
			end
		else if(8'd0 <= score && score <= 8'd2)
			begin
				speed <= 30'd199999999; // 4 Seconds
			end
		else if(8'd2 < score && score <= 8'd5)
			begin
				speed <= 30'd099999999; // 2 Seconds
			end
		else if(8'd5 < score && score <= 8'd10)
			begin
				speed <= 30'd049999999; // 1 Second
			end
		else
			begin
				speed <= 30'd024999999; // 0.5 Second
			end
	end

endmodule

//Only for test in the simulation
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
	wire [29:0] speed;
	
	
	levelController l(
		.clock(clock),
		.game(game),
		.score(score),
		.speed(speed)
	);
	
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


// Uncomment this block to test on the board with SW and LEDR.
// Expected behaviour:
// 1. Push SW[0] to 1
// 2. After 3 seconds, a mole should appear. We do nothing, after 2 seconds, the mole should disappear.
// 3. After another 3 seconds, another mole should appear, say it is mole1, then if we click KEY[0], mole1(LEDR[0]) should turnoff, and we can see that HEX0 begins showing 1
// 4. After another 3 seconds, another mole appears we click the wrong button, the mole should still be there, and HEX0 will be decremented by 1.
// 5. If we push SW[0] back to 0, no mole should appear, and HEX0 should be 0 (I haven't tested it yet.)
module top2(
	input CLOCK_50,
	input [2:0] KEY, 
	input [0:0] SW,
	output [2:0] LEDR,
	output [6:0] HEX0,
	output [6:0] HEX1,
	
	output VGA_CLK,   						//	VGA Clock
	output VGA_HS,							//	VGA H_SYNC
	output VGA_VS,							//	VGA V_SYNC
	output VGA_BLANK_N,						//	VGA BLANK
	output VGA_SYNC_N,						//	VGA SYNC
	output [9:0] VGA_R,   						//	VGA Red[9:0]
	output [9:0] VGA_G,	 						//	VGA Green[9:0]
	output [9:0] VGA_B   						//	VGA Blue[9:0]

);
	
	wire turnoffWire;
	wire [7:0] score;
	wire [29:0] speed;
	wire mole1, mole2, mole3;
	
	reg draw;
	reg [1:0] coord;
	
	
   always @(*)
   begin
		if(mole1 == 1) begin
			coord = 10;
			draw = 1;
		end
		else if(mole2 == 1) begin
			coord = 01;
			draw = 1;
		end
		else if (mole3 == 1) begin
			coord = 00;
			draw = 1;
		end
		else begin
			draw = 0;
		end
   end
	
	
	paint myPaint1(
		.CLOCK_50(CLOCK_50),						//	On Board 50 MHz
		.coord(coord),
		.mole(draw),
		.reset(~game),
		.VGA_CLK(VGA_CLK),   						//	VGA Clock
		.VGA_HS(VGA_HS),							//	VGA H_SYNC
		.VGA_VS(VGA_VS),							//	VGA V_SYNC
		.VGA_BLANK_N(VGA_BLANK_N),						//	VGA BLANK
		.VGA_SYNC_N(VGA_SYNC_N),						//	VGA SYNC
		.VGA_R(VGA_R),   						//	VGA Red[9:0]
		.VGA_G(VGA_G),	 						//	VGA Green[9:0]
		.VGA_B(VGA_B)   						//	VGA Blue[9:0]
	);
	
	levelController l(
		.clock(clock),
		.game(game),
		.score(score),
		.speed(speed)
	);
	
	player p(
		.clock(CLOCK_50),
		.button1(~KEY[0]),
		.button2(~KEY[1]),
		.button3(~KEY[2]),
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
		.speed(speed),
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



module milestone1(
  //Clock Input (50 MHz)
  input  CLOCK_50,
  //Push Buttons
  input  [3:0]  KEY,
  //DPDT Switches 
  //7-SEG Displays
  //LEDs
  output  [8:0]  LEDG,  //  LED Green[8:0]
  output  reg [17:0]  LEDR,  //  LED Red[17:0]
  //PS2 data and clock lines		
  input	PS2_DAT,
  input	PS2_CLK,
  //GPIO Connections
  inout  [35:0]  GPIO_0, GPIO_1
);

//set all inout ports to tri-state
assign  GPIO_0    =  36'hzzzzzzzzz;
assign  GPIO_1    =  36'hzzzzzzzzz;

wire RST;
assign RST = KEY[0];



//turn off green LEDs
assign LEDG = 0;

wire reset = 1'b0;
wire [7:0] scan_code;

reg [7:0] history[1:4];
wire read, scan_ready;

oneshot pulser(
   .pulse_out(read),
   .trigger_in(scan_ready),
   .clk(CLOCK_50)
);

keyboard kbd(
  .keyboard_clk(PS2_CLK),
  .keyboard_data(PS2_DAT),
  .clock50(CLOCK_50),
  .reset(reset),
  .read(read),
  .scan_ready(scan_ready),
  .scan_code(scan_code)
);

wire [5:0] HEX0;
wire [5:0] HEX1;

hex_7seg dsp0(history[1][3:0],HEX0);
hex_7seg dsp1(history[1][7:4],HEX1);


always @(*)
begin
	if(HEX0 == 6'b001001 && HEX1 == 6'b1111000) begin
		LEDR[0] = 1;
	end
	else begin
		LEDR[0] = 0;
	end
end


always @(posedge scan_ready)
begin
	history[4] <= history[3];
	history[3] <= history[2];
	history[2] <= history[1];
	history[1] <= scan_code;
end

	

//blank remaining digits

wire [6:0] blank = 7'h7f;
assign HEX2 = blank;
assign HEX3 = blank;
assign HEX4 = blank;
assign HEX5 = blank;
assign HEX6 = blank;
assign HEX7 = blank;


endmodule