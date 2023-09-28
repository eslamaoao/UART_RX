module UART_RX 
(
input wire RX_IN,
input wire PAR_EN,
input wire PAR_TYP,
input wire [5:0] Prescale,

input wire CLK,RST,


output wire [7:0] P_DATA,
output wire data_valid

);



wire 	   dat_samp_en_wire ;
wire [4:0] edge_cnt_wire    ;
wire [3:0] bit_cnt_wire     ;
wire 	   sampled_bit_wire ;
wire 	   deser_en_wire    ;
wire 	   enable_wire      ;


wire stp_err_wire	 		;
wire strt_glitch_wire		;
wire par_err_wire			;
wire par_chk_en_wire		;
wire strt_chk_en_wire		;
wire stp_chk_en_wire		;





data_sampling U0
(
.Prescale 		(Prescale),
.dat_samp_en 	(dat_samp_en_wire),
.edge_cnt 		(edge_cnt_wire),
.RX_IN 			(RX_IN),
.CLK 			(CLK),
.RST 			(RST),
.sampled_bit	(sampled_bit_wire)
);



deserializer U1
(
.sampled_bit 	(sampled_bit_wire),
.deser_en  		(deser_en_wire),
.Prescale       (Prescale),
.CLK 			(CLK),
.RST 			(RST),
.P_DATA 		(P_DATA)
);



edge_bit_counter U2
(
.enable 		(enable_wire),
.Prescale 		(Prescale),
.CLK 			(CLK),
.RST 			(RST),
.bit_cnt 		(bit_cnt_wire),
.PAR_EN         (PAR_EN),
.edge_cnt 		(edge_cnt_wire)
);



FSM U3
(
.RX_IN 			(RX_IN),
.PAR_EN 		(PAR_EN),
.bit_cnt 		(bit_cnt_wire),
.stp_err		(stp_err_wire),
.strt_glitch 	(strt_glitch_wire),
.par_err 		(par_err_wire),
.CLK 			(CLK),
.RST 			(RST),
.enable 		(enable_wire),
.deser_en 		(deser_en_wire),
.dat_samp_en 	(dat_samp_en_wire),
.par_chk_en 	(par_chk_en_wire),
.strt_chk_en 	(strt_chk_en_wire),
.stp_chk_en 	(stp_chk_en_wire),
.data_valid 	(data_valid),
.edge_cnt		(edge_cnt_wire),
.Prescale 		(Prescale)
);




parity_Check U4
(
.P_DATA 		(P_DATA),
.PAR_TYP 		(PAR_TYP),
.par_chk_en 	(par_chk_en_wire),
.sampled_bit 	(sampled_bit_wire),
.CLK 			(CLK),
.RST 			(RST),
.par_err 		(par_err_wire)
);



stop_Check U5
(
.stp_chk_en 	(stp_chk_en_wire),
.sambled_bit 	(sampled_bit_wire),
.CLK 			(CLK),  
.RST 			(RST),
.stp_err 		(stp_err_wire)
);



strt_Check U6
(
.strt_chk_en 	(strt_chk_en_wire),
.sambled_bit 	(sampled_bit_wire),
.CLK 			(CLK),
.RST 			(RST),
.strt_glitch 	(strt_glitch_wire)
);
endmodule