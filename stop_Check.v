module stop_Check 
(
input wire stp_chk_en,
input wire sambled_bit,

input wire CLK,RST,

output reg stp_err

);


always@(posedge CLK or negedge RST)
 begin
	if(!RST)
	 begin
		stp_err <= 1'b0;
	 end
	else if (stp_chk_en)
	 begin
		if(sambled_bit == 1'b1)
			stp_err <= 1'b0;
		else
			stp_err <= 1'b1;
	 end
	else
		stp_err <= 1'b0;
 end
 
 endmodule