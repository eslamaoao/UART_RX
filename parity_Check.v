module parity_Check 
(
input wire [7:0] P_DATA,
input wire PAR_TYP,
input wire par_chk_en,
input wire sampled_bit,
input wire CLK,RST,
output reg par_err 
);

wire temp;
always@(posedge CLK or negedge RST)
 begin
	if (!RST)
		par_err <= 1'b0;
	else if (par_chk_en)
		begin
			if (PAR_TYP)
				begin
					if (temp==1'b1 && sampled_bit == 1'b0 )
						par_err <= 1'b0;
					else if (temp==1'b0 && sampled_bit == 1'b1 )
						par_err <= 1'b0;
					else
						par_err <= 1'b1;
				end
			else
				begin
					if(temp==1'b1 && sampled_bit == 1'b1)
						par_err <= 1'b0;
					else if(temp==1'b0 && sampled_bit == 1'b0)
						par_err <= 1'b0;
					else
						par_err <= 1'b1;
				end
					
		end	
	else
		par_err <= 1'b0;
 end
		
assign temp = ^P_DATA;
endmodule