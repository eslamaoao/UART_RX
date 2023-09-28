module strt_Check 
(
input wire strt_chk_en,
input wire sambled_bit,

input wire CLK,RST,

output reg strt_glitch
);

always@(posedge CLK or negedge RST)
 begin
	if(!RST)
	 begin
		strt_glitch <= 1'b0;
	 end
	else if (strt_chk_en)
	 begin
		if(sambled_bit == 1'b0)
			strt_glitch <= 1'b0;
		else
			strt_glitch <= 1'b1;
	 end
	else
		strt_glitch <= 1'b0;
		
 end
 
 endmodule