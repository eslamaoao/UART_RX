module deserializer 
(
input wire 		 sampled_bit,
input wire 		 deser_en,
input wire [5:0] Prescale,
input wire 	 	 CLK,RST,

output reg [7:0] P_DATA

);
wire count_max ;
reg [7:0] shift_reg ;
reg [4:0] count		;
always@(posedge CLK or negedge RST)
 begin
	if(!RST)
	 begin
		P_DATA 	  <= 8'b0;
		shift_reg <= 8'b0;
	 end
	else if (deser_en && count_max)
	 begin
		shift_reg[7] <= sampled_bit;
		shift_reg[6] <= shift_reg[7];
		shift_reg[5] <= shift_reg[6];
		shift_reg[4] <= shift_reg[5];
		shift_reg[3] <= shift_reg[4];
		shift_reg[2] <= shift_reg[3];
		shift_reg[1] <= shift_reg[2];
		shift_reg[0] <= shift_reg[1];
	 end
	else
		P_DATA <= shift_reg;
 end
 
 always@(posedge CLK or negedge RST)
  begin
	if(!RST)	
		begin
			count <= (Prescale-1);
		end
	else if (deser_en)
		begin
			if (!count_max)
				begin
					count <= count + 1'b1;
				end
			else 
				begin
					count <= 'b0;
				end	
		end
	else
		begin
			
		end
	
  end
 
 
 assign count_max = ( count == (Prescale-1)); 
 endmodule
 