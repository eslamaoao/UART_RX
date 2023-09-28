module FSM
	(
		input wire RX_IN,
		input wire PAR_EN,
		input wire [3:0] bit_cnt,
		input wire [4:0] edge_cnt, 
		input wire stp_err,
		input wire strt_glitch,
		input wire par_err,
		input wire [5:0] Prescale,
		input wire CLK,RST,

		output reg enable,
		output reg deser_en,
		output reg dat_samp_en,
		output reg par_chk_en,
		output reg strt_chk_en,
		output reg stp_chk_en,

		output reg data_valid
		);
		
	
	
	localparam [2:0]  IDLE        = 4'b0000,
					  start_chk   = 4'b0001,
					  receiving   = 4'b0011,
					  parity_chk  = 4'b0010,
					  stop_chk    = 4'b0110,
					  valid		  =	4'b0111;
		
		
	
	reg  	  [2:0] current_state,next_state ;			  
	always@(posedge CLK or negedge RST)
	 begin
		if(!RST)
			begin
				current_state <= IDLE ;
			end
		else
			begin
				current_state <= next_state ;
			end
	 end
 
	
	always@(*)
     begin
		case(current_state)
	
		IDLE 		:	begin
							if(!RX_IN)
								next_state = start_chk;
							else
								next_state = current_state;
						end
				
		start_chk 	:   begin 
							if((bit_cnt == 4'd0 ) && (edge_cnt == (Prescale-1))) 
								next_state = receiving;
							else
								next_state = start_chk;
						end
		
		receiving	:   begin
							if (strt_glitch == 1'b0)
									next_state = receiving;
								else
									next_state = IDLE;
							if(bit_cnt == 4'd8 && edge_cnt == (Prescale-1))
								if(PAR_EN)
									next_state = parity_chk;
								else
									next_state = stop_chk  ;
							else
								next_state = receiving;
						end
		
		parity_chk  :	begin
							if(bit_cnt == 4'd9 && edge_cnt == (Prescale-1))
								next_state = stop_chk;
							
							else
								next_state = parity_chk;
							 
								
							
						end

		stop_chk 	:   begin
							if (par_err)
									next_state = IDLE;
								else
									next_state = stop_chk;	
							if((bit_cnt == 4'd10 && edge_cnt == (Prescale-1)) || (bit_cnt == 4'd9) && (edge_cnt == (Prescale-1))) 
							 begin
								
									next_state = valid;
							 end
							else
								next_state = stop_chk;
						end 
						
		valid		:	begin
							if (stp_err)
								next_state = IDLE;
							else if (!RX_IN)
								next_state = start_chk;
							else
								next_state = IDLE ;
							
						end
		default :   next_state = IDLE ;	
		endcase
	 end
		 
		 
		 
	
	always@(*)
     begin
		data_valid 	 = 1'b0;
		enable		 = 1'b0;
		deser_en	 = 1'b0;
		dat_samp_en	 = 1'b0;
		par_chk_en	 = 1'b0;
		strt_chk_en	 = 1'b0;
		stp_chk_en	 = 1'b0;
		case(current_state)
	
		IDLE 		:	begin
							if(!RX_IN)
								begin
									enable		 = 1'b1;
									dat_samp_en	 = 1'b1;
									
								end
							else
								data_valid 	 	 = 1'b0;
						end
				
		start_chk 	:   begin
							enable		 = 1'b1;
							dat_samp_en	 = 1'b1;
							
						end
		
		receiving	:   begin
							if (bit_cnt == 1)
								strt_chk_en	= 1'b1;
							if(!(bit_cnt == 4'd1 || bit_cnt == 4'd0))
								deser_en = 1'b1;
							enable		 = 1'b1;
							dat_samp_en	 = 1'b1;
							
							
							if ((edge_cnt== (Prescale-1)||edge_cnt=='d0) && bit_cnt == 10)
								par_chk_en = 1'b1;
						end
		
		parity_chk  :	begin
							if((bit_cnt == 4'd9 && edge_cnt=='d0))
								deser_en = 1'b1;
							par_chk_en	 = 1'b1;
							enable		 = 1'b1;
							dat_samp_en	 = 1'b1;
						end

		stop_chk 	:   begin
							if((bit_cnt == 4'd9 && edge_cnt=='d0))
								deser_en = 1'b1;
								
							stp_chk_en	 = 1'b1;
							enable		 = 1'b1;
							dat_samp_en	 = 1'b1;
						end 
						
		valid		:	begin
								
							data_valid 	 = 1'b1;
							enable		 = 1'b1;	
						end
						
		default 	:   begin
							data_valid 	 = 1'b0;
							enable		 = 1'b0;
							deser_en	 = 1'b0;
							dat_samp_en	 = 1'b0;
							par_chk_en	 = 1'b0;
							strt_chk_en	 = 1'b0;
							stp_chk_en	 = 1'b0;
						end
		endcase
	 end
	 
		
		
		
endmodule