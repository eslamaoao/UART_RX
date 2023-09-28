module edge_bit_counter 
	(
			input wire 		 enable,
			input wire [5:0] Prescale,
			input wire PAR_EN,

			input wire CLK,RST,


			output wire [3:0] bit_cnt,
			output wire [4:0] edge_cnt
			);



	reg [4:0] edge_count;
	reg [3:0] bit_count;
	wire count_edge_max;
	
	/*always@(*)
	 begin
		if(Prescale =='d31)
		 begin
			if (edge_count == (Prescale))
				count_edge_max = 1'b1;
			else
				count_edge_max = 1'b0;
		 end
		else
		 begin
			if (edge_count == ((Prescale )-1))
				count_edge_max = 1'b1;
			else
				count_edge_max = 1'b0;
		 end
	 end
*/
	assign count_edge_max = (edge_count == ((Prescale )-1));
	assign bit_cnt = bit_count ;
	assign edge_cnt = edge_count ;
	always@(posedge CLK or negedge RST)
	 begin
		if(!RST)
		 begin
			edge_count <=5'b0;
			bit_count  <=4'b0;
		 end
		else
		 begin
			if(enable) 
			 begin
				if(!count_edge_max)
				 begin
					edge_count <= edge_count + 1 ;
				 end
				else
				 begin
					edge_count <= 5'b0;
					if(PAR_EN)
					 begin
						if(bit_count == 4'd10)
							bit_count <= 4'd0;
						else
							bit_count <= bit_count  + 1 ;
					 end
					else
						begin
							if(bit_count == 4'd9)
							bit_count <= 4'd0;
						else
							bit_count <= bit_count  + 1 ;
						end
						
				 end
			 end
			else
			 begin
				bit_count  <= 4'b0 ;
				edge_count <= 5'b0;
			 end
		 end
		
	 end
endmodule