// Part 2 skeleton
module parttwo
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
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
	input   [9:0]   SW;
	input   [3:0]   KEY;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
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
		// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
		// for the VGA controller, in addition to any other functionality your design may require.
		
		 // Instansiate datapath
		datapath d0(	
						.clk(CLOCK_50),
						.enable(enable),
						.ld_x(ldx),
						.ld_y(ldy),
						.ld_color(ldc),
						.reset_n(resetn),
						.color_in(SW[9:7]),
						.coord(SW[6:0]),
						.x_out(x),
						.y_out(y),
						.color_out(colour));						
		 // Instansiate FSM control
		control c0(.clk(CLOCK_50),
		 .resetn(resetn),
		 .xstuff(KEY[1]),
		 .plot(KEY[3]),
		 .stop(stop),
		 .load_x(load_x),
		 .load_y(load_y), 
		 .count(count), 
		 .ld_result_x(ld_result_x),
		 .ld_result_y(ld_result_y), 
		 .load_col(load_col),
		 .enable(writeEn)
		 );

endmodule


module datapath(	
		input clk,
		input ld_x, ld_y, ld_color,
		input reset_n, enable,
		input [2:0] color_in,
		input [6:0] coord,
		output [7:0] x_out,
		output [6:0] y_out,
		output [2:0] color_out
	);

	reg [2:0] count_x, count_y;
	reg [7:0] x;
	reg [6:0] y;
	reg [2:0] color;
	wire y_enable;
	wire [1:0] rate_count_down;

	// registors for x, y and color
	always @(posedge clk) begin
		if (!reset_n) begin
			x <= 8'b0;
			y <= 7'b0;
			color <= 3'b0;
		end
		else begin
			if (ld_x)
				x <= {1'b0, coord};
			if (ld_y)
				y <= coord;
			if (ld_color)
				color <= color_in;
		end
	end

	// counter for x
	always @(posedge clk) begin
		if (!reset_n)
			count_x <= 2'b00;
		else if (enable) begin
			if (count_x == 2'b11)
				count_x <= 2'b00;
			else begin
				count_x <= count_x + 1'b1;
			end
		end
	end
	
	// when x gets to 4, you let y increase by 1 (To draw square)
	assign y_enable = (count_x == 2'b11) ? 1 : 0;

	// counter for y
	always @(posedge clk) begin
		if (!reset_n)
			count_y <= 2'b00;
		else if (enable && y_enable) begin
			if (count_y != 2'b11)
				count_y <= count_y + 1'b1;
			else 
				count_y <= 2'b00;
		end
	end
	// output coordinates
	assign x_out = x + count_x;
	assign y_out = y + count_y;
	assign color_out = color;
endmodule

module control(

    input clk,

    input resetn,

    input xstuff,

	 input plot,

	 input stop,

    output reg load_x, load_y, count, ld_result_x, ld_result_y, load_col, enable

    );



    reg [5:0] current_state, next_state; 

    

    localparam  S_LOAD_X        = 4'd0,

                S_LOAD_X_WAIT   = 4'd1,

                S_LOAD_Y        = 4'd2,

                S_LOAD_Y_WAIT   = 4'd3,

                S_CYCLE_0       = 4'd4,

                S_CYCLE_1       = 4'd5;

 

    

    // Next state logic aka our state table ????

    always@(*)

    begin: state_table 

            case (current_state)

                S_LOAD_X: next_state = xstuff ? S_LOAD_X_WAIT : S_LOAD_X; // Loop in current state until value is input

                S_LOAD_X_WAIT: next_state = xstuff ? S_LOAD_X_WAIT : S_LOAD_Y; // Loop in current state until go signal goes low

                S_LOAD_Y: next_state = plot ? S_LOAD_Y_WAIT : S_LOAD_Y; // Loop in current state until value is input

                S_LOAD_Y_WAIT: next_state = plot ? S_LOAD_Y_WAIT : S_CYCLE_0; // Loop in current state until go signal goes low

                S_CYCLE_0: next_state = S_CYCLE_1;

                S_CYCLE_1: next_state = stop ? S_LOAD_X : S_CYCLE_0; // we will be done our two operations, start over after

            default:     next_state = S_LOAD_X;

        endcase

    end // state_table

   



    always @(*)

    begin: enable_signals

        // By default make all our signals 0

        load_x = 1'b0;

        load_y = 1'b0;

        count = 1'b0;

		  ld_result_x = 1'b0;

		  ld_result_y = 1'b0;

		  enable = 1'b0;

		  load_col = 1'b0;



        case (current_state)

            S_LOAD_X: begin

                load_x = 1'b1;

                end

            S_LOAD_Y: begin

                load_y = 1'b1;

					 load_col = 1'b1;

                end

            S_CYCLE_0: begin

				    ld_result_x = 1'b1;

					 ld_result_y = 1'b1;

					end

            S_CYCLE_1: begin

					 enable = 1'b1;

					 count = 1'b1;

					end

        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block

        endcase

    end // enable_signals

   

    // current_state registers

    always@(posedge clk)

    begin: state_FFs

        if(!resetn)

            current_state <= S_LOAD_X;

        else

            current_state <= next_state;

    end // state_FFS

endmodule

