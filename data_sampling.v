module data_sampling 
	(
				input wire [5:0] 	Prescale,
				input wire 			dat_samp_en,
				input wire  [4:0] 	edge_cnt, 
				input wire 		 	RX_IN,

				input wire 			CLK,RST,

				output reg 			sampled_bit
				);



	reg  [2:0] tmp_sampled;
	wire [4:0] before_middle;
	wire [4:0] middle;
	wire [4:0] after_middle;
	
	assign middle		 = (Prescale  >> 1)     ;
	assign before_middle = ((Prescale >> 1) - 2);
	assign after_middle  = ((Prescale >> 1) - 1);
	
	always@(posedge CLK or negedge RST) /////// that always to just capture the datavalue at the middle of the clock period and after and before it with one clock cycle
	 begin
		if(!RST)
		 begin
			tmp_sampled <= 3'b0;
		 end
		else if(dat_samp_en)
		 begin
			if(edge_cnt == before_middle)
			 begin
				tmp_sampled[0] <= RX_IN ;
			 end
			else if (edge_cnt == middle)
			 begin
				tmp_sampled[1] <= RX_IN ;
			 end
			else if (edge_cnt == after_middle)
			 begin
				tmp_sampled[2] <= RX_IN ;
			 end
		 end
		
		else
		 begin
			tmp_sampled <= 3'b0;
		 end
		
	end
	
	
	always@(posedge CLK or negedge RST) //////// that always for determining which value will be sent as a sampled_bit
	 begin
		if(!RST)
		 begin
			sampled_bit <= 1'b0;
		 end
		
		else 
		 begin
			if(dat_samp_en)					
			 begin
				if(tmp_sampled[0] == tmp_sampled[1]) //// to know which value should be sent as a sampled_bit we need to check the value of before and after and middle and compare it 
				 begin							    ///// we have a combination of {before && middle, before && after, middle && after}
					sampled_bit <= tmp_sampled[0];
				 end
				else if ((tmp_sampled[0]==tmp_sampled[2]) || (tmp_sampled[1]==tmp_sampled[2]))
				 begin
					sampled_bit <= tmp_sampled[2];
				 end
			 end
			 
			else
			 begin
				sampled_bit <= 1'b0;
			 end
				
			
		 end
		 
		 
	 end
	

endmodule