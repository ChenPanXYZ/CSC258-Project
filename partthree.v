module top(

		input CLOCK_50,						//	On Board 50 MHz
      input [9:0]SW,
		input [3:0]KEY,

		output VGA_CLK,   					//	VGA Clock
		output VGA_HS,							//	VGA H_SYNC
		output VGA_VS,							//	VGA V_SYNC
		output VGA_BLANK_N,					//	VGA BLANK
		output VGA_SYNC_N,					//	VGA SYNC
		output [9:0]VGA_R,   				//	VGA Red[9:0]
		output [9:0]VGA_G,	 				//	VGA Green[9:0]
		output [9:0]VGA_B   					//	VGA Blue[9:0]
		);
		wire	[7:0]curr_x;
		wire	[6:0]curr_y;
		wire  x_dir;
		wire  y_dir;

		wire resetn;
		assign resetn = KEY[0];
		// Create the colour, x, y and writeEn wires that are inputs to the controller.

		wire [2:0] colour;

		wire [7:0] x;

		wire [6:0] y;

		wire writeEn;

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
		//figures out when and where to draw the block
		datapath d0(
		 .clock(CLOCK_50),
		 .resetn(reset_n),
		 .x_dir(x_dir),
		 .y_dir(y_dir),
		 .colourIn(SW[9:7]),
		 .ld_colour(colour),
		 .enable(count),
		 // these two are outputs for x and y
		 .data_result_x(x),
		 .data_result_y(y),
		 .colour(colour),
		 );
		 //does collisions and direction
		 control c0(.clk(CLOCK_50),
		 .resetn(resetn),
		 .xstuff(KEY[1]),
		 .plot(KEY[3]),
		 .stop(stop),
		 .curr_X(x),
		 .curr_y(y),
		 .x_dir(x_dir),
		 .y_dir(y_dir),
		 .load_col(load_col),
		 .enable(writeEn)
		 );
endmodule

module datapath(
	input clock,
	input resetn,
	input x_dir,
	input y_dir,
	input [2:0] colourIn, 
	input ld_colour,enable,
	output reg [7:0] data_result_x,
	output reg [6:0] data_result_y,
	output reg [2:0] colour,
	output reg [3:0]frame
);
	// register inputs
	reg[6:0] x;
	reg[6:0] y;
	reg[19:0] count;

	always @ (posedge clock) begin
        if (!resetn) begin
					x <= 8'd0; 
					y <= 7'd60;
					colour <= 3'b0;
			  end
        else begin
				//maybe dont need these two lines?
				//x <= curr_X;
				//y <= curr_y;
				if(ld_colour) begin
					colour <= colourIn;
					end
			end
    end
	
		// counter
	 always @ (posedge clock) begin
		if (!resetn)
			begin
				count <= 4'b0000;
			end
		if (enable)
			begin
				//by lab 5, 1Hz == 50000000 so 60Hz is 50000000/60
				if (count == 6'd833333) begin
					count <= 0;
					frame <= frame + 1;	
				end
				//move every 15 frames
				if (frame == 2'd15) begin
					frame <= 0;
				end
				else begin
					count <= count + 1;
				end
			end
	end

    // Output result register
    always @ (posedge clock) begin

        if (!resetn) begin
            data_result_x <= 8'd0; 
				data_result_y <= 7'd60; 
        end

        else begin

				if(frame == 0) begin
					//if its 1 then increase its x coord by 1 and repeat for y coord
					if (x_dir > 0) begin
						data_result_x <= x + 1'b1;
					end
					else begin
						data_result_x <= x - 1'b1;
					end
					if (y_dir > 0) begin
						data_result_y <= x + 1'b1;
					end
					else begin
						data_result_y <= x - 1'b1;
					end
				end
		  end
    end

endmodule



module control(
    input clk,
    input resetn,
	 input curr_x, 
	 input curr_y,
    output reg x_dir, 
	 output reg y_dir, 
	 output reg load_col, 
	 output reg enable
    );
    reg [5:0] current_state, next_state;

	 localparam top = 1d'0;
	 localparam bottom = 3d'126;
	 localparam	left = 1d'0;
	 localparam right	= 3d'156;

    localparam downright = 4'd0;
	 localparam downrightcollide = 4'd1;
	 localparam upright = 4'd2;
	 localparam uprightcollide = 4'd3;
	 localparam upleft = 4'd4;
	 localparam upleftcollide = 4'd5;
	 localparam downleft = 4'd5;
	 localparam downleftcollide = 4'd6;
    
    always@(*)
    begin: state_table 
				//make sure it does not collide with walls
            case (current_state)
					downright: next_state = (curr_x < right && curr_y < bottom) ? downright : downrightcollide; 
					downrightcollide: next_state = (curr_X == right) ?  downleft : upright;
					upright: next_state = (curr_x < right && curr_y > top) ? upright : uprightcollide;
					uprightcollide: next_state = (curr_x == right) ? upleft : downright;
					upleft: next_state = (curr_x > left && curr_y > top) ? upleft : upleftcollide;
					upleftcollide: next_state = (curr_x == left) ? upright: downleft;
					downleft: next_state = (curr_x > left, curr_y < bottom) ? downleft : downleftcollide;
					downleftcollide: next_state = (curr_x == left) ? downright : upleft;
				default:	next_state = downright;
        endcase
    end

    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        count = 1'b0;
		  ld_result_x = 1'b0;
		  ld_result_y = 1'b0;
		  enable = 1'b0;
		  load_col = 1'b0;

        case (current_state)
				downright: begin
					x_dir = 1;
					y_dir = 1;
					end
				upright:
					x_dir = 1;
					y_dir = -1;
					end
				upleft: begin
					x_dir = -1;
					y_dir = -1;
					end
				downleft: begin
					x_dir = -1;
					y_dir = 1;
					end
        // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end 

    // current_state registers
    always@(posedge clk)
    begin: state_FFs
		  //resetn is active low
        if(!resetn)
            current_state <= downright;
        else
            current_state <= next_state;
    end // state_FFS
endmodule