//module draw
//	(
//		CLOCK_50,						//	On Board 50 MHz
//		SW,
//		VGA_CLK,   						//	VGA Clock
//		VGA_HS,							//	VGA H_SYNC
//		VGA_VS,							//	VGA V_SYNC
//		VGA_BLANK_N,						//	VGA BLANK
//		VGA_SYNC_N,						//	VGA SYNC
//		VGA_R,   						//	VGA Red[9:0]
//		VGA_G,	 						//	VGA Green[9:0]
//		VGA_B   						//	VGA Blue[9:0]
//	);
//	
//	input			CLOCK_50;				//	50 MHz
//	input [4:0] SW;
//
//	output			VGA_CLK;   				//	VGA Clock
//	output			VGA_HS;					//	VGA H_SYNC
//	output			VGA_VS;					//	VGA V_SYNC
//	output			VGA_BLANK_N;				//	VGA BLANK
//	output			VGA_SYNC_N;				//	VGA SYNC
//	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
//	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
//	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
//	
//	paint a1 (
//		.CLOCK_50(CLOCK_50),	
//		.coord(SW[1:0]), // input for which block to draw
//		.col(SW[4:2]),	//input for which colour
//		.VGA_CLK(VGA_CLK),   						
//		.VGA_HS(VGA_HS),							
//		.VGA_VS(VGA_VS),							
//		.VGA_BLANK_N(VGA_BLANK_N),						
//		.VGA_SYNC_N(VGA_SYNC_N),						
//		.VGA_R(VGA_R),   						
//		.VGA_G(VGA_G),	 						
//		.VGA_B(VGA_B)   		
//	);
//
//
//endmodule


module paint
	(
		CLOCK_50,						//	On Board 50 MHz
		coord,
		col,
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input [1:0] coord;
	input [2:0] col;

	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	
	wire [2:0] colour;
	wire [7:0] x;
	// height of 33 pixels down from top left
	wire [6:0] y = 6'b100001;
	wire writeEn;
	
	
	output reg [5:0] x;
   always @(*)
   begin
       case(coord)
           2'b00: x = 6'b000001;//x set to 1
           2'b01: x = 6'b000011;//x set to 3
           2'b10: x = 6'b000101;//x set to 5
           default: x = 6'b000001;
       endcase
   end
	 
	output reg [2:0] colour;
   always @(*)
   begin
       case(col)
           3'b000: colour = 3'b000;//set colour of block to black
           3'b001: colour = 3'b001;//set colour to whatever colour this is
           default: colour = 3'b100;
       endcase
   end

	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
		
endmodule