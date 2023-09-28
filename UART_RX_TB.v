
`timescale 1ns/1ps

module UART_RX_TB ();

/////////////////////////////////////////////////////////
///////////////////// Parameters ////////////////////////
/////////////////////////////////////////////////////////

parameter DATA_WIDTH = 8 ;  
parameter RX_CLK_PERIOD = 10 ; 

/////////////////////////////////////////////////////////
//////////////////// DUT Signals ////////////////////////
/////////////////////////////////////////////////////////

reg                         RX_CLK_TB;
reg                         RST_TB;
reg                         RX_IN_TB;
reg   [5:0]                 Prescale_TB;
reg                         parity_enable_TB;
reg                         parity_type_TB;
wire  [DATA_WIDTH-1:0]      P_DATA_TB; 
wire                        data_valid_TB;
wire                        parity_error_TB;
wire                        framing_error_T;

reg                         TX_CLK_TB;

////////////////////////////////////////////////////////
////////////////// initial block /////////////////////// 
////////////////////////////////////////////////////////

initial
 begin

 // Initialization
 initialize() ;

 // Reset
 reset() ; 

 ////////////// Test Case 1 //////////////////

 // UART Configuration (Parity Enable = 1 && Parity Type = 1 && Prescale = 32)
 UART_CONFG (1'b1,1'b1,6'd32);
 
 // Load Data 
 DATA_IN(8'hBB);  

 // Check Output
 chk_rx_out(8'hBB,1) ;
 
 ////////////// Test Case 2 //////////////////

 // UART Configuration (Parity Enable = 1 && Parity Type = 0 && Prescale = 32)
 UART_CONFG (1'b1,1'b0,6'd32);
 
 // Load Data 
 DATA_IN(8'hBB);  

 // Check Output
 chk_rx_out(8'hBB,2) ;
 
 ////////////// Test Case 3 //////////////////

 // UART Configuration (Parity Enable = 0 && Parity Type = 0 && Prescale = 32)
 UART_CONFG (1'b0,1'b0,6'd32);
 
 // Load Data 
 DATA_IN(8'hBB);  

 // Check Output
 chk_rx_out(8'hBB,3) ;
 
 ////////////// Test Case 4 //////////////////

 // UART Configuration (Parity Enable = 1 && Parity Type = 1 && Prescale = 16)
 UART_CONFG (1'b1,1'b1,6'd16);
 
 // Load Data 
 DATA_IN(8'hBB);  

 // Check Output
 chk_rx_out(8'hBB,4) ;
 
 ////////////// Test Case 5 //////////////////

 // UART Configuration (Parity Enable = 1 && Parity Type = 0 && Prescale = 32)
 UART_CONFG (1'b1,1'b0,6'd16);
 
 // Load Data 
 DATA_IN(8'hBB);  

 // Check Output
 chk_rx_out(8'hBB,5) ;
 
  ////////////// Test Case 6 //////////////////

 // UART Configuration (Parity Enable = 0 && Parity Type = 0 && Prescale = 16)
 UART_CONFG (1'b0,1'b0,6'd16);
 
 // Load Data 
 DATA_IN(8'hBB);  

 // Check Output
 chk_rx_out(8'hBB,6) ;
 
  ////////////// Test Case 7 //////////////////

 // UART Configuration (Parity Enable = 1 && Parity Type = 1 && Prescale = 8)
 UART_CONFG (1'b1,1'b1,6'd8);
 
 // Load Data 
 DATA_IN(8'hBB);  

 // Check Output
 chk_rx_out(8'hBB,7) ;
 
  ////////////// Test Case 8 //////////////////

 // UART Configuration (Parity Enable = 1 && Parity Type = 1 && Prescale = 8)
 UART_CONFG (1'b1,1'b0,6'd8);

 // Load Data 
 DATA_IN(8'hBB);  

 // Check Output
 chk_rx_out(8'hBB,8) ;
 
 ////////////// Test Case 9 //////////////////

 // UART Configuration (Parity Enable = 1 && Parity Type = 1 && Prescale = 8)
 UART_CONFG (1'b0,1'b0,6'd8);
 
 // Load Data 
 DATA_IN(8'hBB);  

 // Check Output
 chk_rx_out(8'hBB,9) ;
 
#4000

$stop ;

end
 
///////////////////// Clock Generator //////////////////

always #(RX_CLK_PERIOD/2) RX_CLK_TB = ~RX_CLK_TB ;

always #(Prescale_TB*RX_CLK_PERIOD/2) TX_CLK_TB = ~TX_CLK_TB ;

////////////////////////////////////////////////////////
/////////////////////// TASKS //////////////////////////
////////////////////////////////////////////////////////

/////////////// Signals Initialization //////////////////

task initialize ;
  begin
	RX_CLK_TB         = 1'b0      ;
	TX_CLK_TB         = 1'b0      ;
	RST_TB            = 1'b1      ;    // rst is deactivated
	Prescale_TB       = 6'b100000 ;    // prescale = 32
	parity_enable_TB  = 1'b1      ;
	parity_type_TB    = 1'b0      ;
	RX_IN_TB          = 1'b1      ;
  end
endtask

///////////////////////// RESET /////////////////////////
task reset ;
  begin
	#(RX_CLK_PERIOD)
	RST_TB  = 'b0;           // rst is activated
	#(RX_CLK_PERIOD)
	RST_TB  = 'b1;
	#(RX_CLK_PERIOD) ;
  end
endtask

///////////////////// Configuration ////////////////////
task UART_CONFG ;
  input                   PAR_EN ;
  input                   PAR_TYP ;
  input    [5:0]          PRESCALE;

  begin
	parity_enable_TB  = PAR_EN   ;
	parity_type_TB    = PAR_TYP  ;
	Prescale_TB       = PRESCALE ;    	
  end
endtask

/////////////////////// Data IN /////////////////////////
task DATA_IN ;
 input  [DATA_WIDTH-1:0]  DATA ;

 integer   i  ;
 
 begin
	
	@ (posedge TX_CLK_TB)  
	RX_IN_TB <= 1'b0 ;              // start_bit

	for(i=0; i<8; i=i+1)
		begin
		@(posedge TX_CLK_TB) 		
		RX_IN_TB <= DATA[i] ;       // data bits
		end 

	if(parity_enable_TB)
		begin
			@ (posedge TX_CLK_TB) 
			case(parity_type_TB)
			1'b0 : RX_IN_TB <= ^DATA  ;     // Even Parity
			1'b1 : RX_IN_TB <= ~^DATA ;     // Odd Parity
			endcase	
		end
	
	@ (posedge TX_CLK_TB) 
	RX_IN_TB <= 1'b1 ;              // stop_bit
	
 end
endtask


//////////////////  Check Output  ////////////////////
task chk_rx_out ;
 input  [DATA_WIDTH-1:0]  		expec_out    ;
 input  [4:0]                   Test_NUM;
  
 begin
 
	@(posedge data_valid_TB)	
	if(P_DATA_TB == expec_out) 
		begin
			$display("Test Case %d is succeeded",Test_NUM,);
		end
	else
		begin
			$display("Test Case %d is failed", Test_NUM);
		end
 end
endtask
 
//////////////////////////////////////////////////////// 
///////////////// Design Instaniation //////////////////
////////////////////////////////////////////////////////

UART_RX DUT (
.CLK(RX_CLK_TB),
.RST(RST_TB),
.RX_IN(RX_IN_TB),
.Prescale(Prescale_TB),
.PAR_EN(parity_enable_TB),
.PAR_TYP(parity_type_TB),
.P_DATA(P_DATA_TB), 
.data_valid(data_valid_TB)

);

endmodule

/*
`timescale 1ns/1ps
module UART_RX_TB ();


/////////////////////////////////////////////////////////
///////////////////// Parameters ////////////////////////
/////////////////////////////////////////////////////////


parameter  CLOCK_PERIOD_RX = 0.3125 ; //// (16*200) MHz clock frequency 
parameter  CLOCK_PERIOD_TX = 5 ; //// 200 MHz clock frequency 
parameter  DATA_WD_TB = 11 ; 





///////////////////////////////////////////////////////////
///////////////////// DUT Signals ////////////////////////
/////////////////////////////////////////////////////////

reg RX_IN_TB;
reg PAR_EN_TB;
reg PAR_TYP_TB;
reg [5:0] Prescale_TB;

reg CLK_TB;
reg RST_TB;


wire [7:0] P_DATA_TB;
wire data_valid_TB;
reg CLK_TB_TX;
initial 
 begin
 // Initialization
 initialize() ;

 // Reset
 reset() ; 
 
 
 
 
 
/////////////// Prescale 8 ////////////////////////////////
////////////// Test Case 1 (No Parity)  //////////////////

 // UART Configuration (Parity Enable = 0)
 UART_CONFG (1'b0,1'b0);

 // Recieved Data 
 RX_IN_PAR_OFF('b1101000110);   // data are A3  1010 0011 // 1 stop bit // 0 stop bit ///
 
  // Check Output
 chk_tx_out(8'hA3,'d1);
 
 //#((2*CLOCK_PERIOD_TX) - (9*CLOCK_PERIOD_RX));
 
 
 //------------------
 
 ///////////////////////////// Testing sending two packages without any gabes the start bit will show in the middle of the previous stop bit state 
 wait(data_valid_TB)
 //#(25*CLOCK_PERIOD_RX);
 RX_IN_TB=0;
 #CLOCK_PERIOD_TX ;
  RX_IN_TB=0;
 #CLOCK_PERIOD_TX ;
  RX_IN_TB=0;
 #CLOCK_PERIOD_TX ;
  RX_IN_TB=0;
 #CLOCK_PERIOD_TX ;
  RX_IN_TB=0;
 #CLOCK_PERIOD_TX ;
  RX_IN_TB=1;
 #CLOCK_PERIOD_TX ;
  RX_IN_TB=1;
 #CLOCK_PERIOD_TX ;
  RX_IN_TB=1;
 #CLOCK_PERIOD_TX ;
  RX_IN_TB=1;
 #CLOCK_PERIOD_TX ;
   RX_IN_TB=1;
 #CLOCK_PERIOD_TX ;

 chk_tx_out(8'b11110000,'d2) ;
 
  #(2*CLOCK_PERIOD_TX);

 
 
//////////////// Test Case 2 (Even Parity) ////////////////

 // UART Configuration (Parity Enable = 1 && Parity Type = 0) // even parity 
 UART_CONFG (1'b1,1'b0);

 // Load Data 
 RX_IN_PAR_EN('b10101101000);  // data B4 1011 0100

 // Check Output
 chk_tx_out(8'hB4,'d3) ;
 

#(2*CLOCK_PERIOD_TX);
  
  
  
////////////// Test Case 3 (Odd Parity) ////////////////

 // UART Configuration (Parity Enable = 1 && Parity Type = 1) // odd parity 
 UART_CONFG (1'b1,1'b1);

 // Load Data 
 RX_IN_PAR_EN('b11110100100);  

 // Check Output
 chk_tx_out(8'hD2,'d4) ; 
 #50
 $stop ;
end







/////////////////////// RX_IN_PAR_EN /////////////////////////
task RX_IN_PAR_EN ;
 input  [DATA_WD_TB-1:0]  DATA ;
integer i ;
 begin
	@(posedge CLK_TB_TX)
	for(i=0; i<11; i = i +1 )
	 begin
		RX_IN_TB= DATA[i]  ;
		#CLOCK_PERIOD_TX ;
    end
  end
endtask

/////////////////////// RX_IN_PAR_OFF /////////////////////////

task RX_IN_PAR_OFF ;
 input  [DATA_WD_TB-1:0]  DATA ;
integer i ;
 begin
	@(posedge CLK_TB_TX)
	for(i=0; i<10; i = i +1 )
	 begin
		RX_IN_TB= DATA[i]  ;
		#CLOCK_PERIOD_TX ;
    end
  end
endtask


/////////////// Signals Initialization //////////////////

task initialize ;
  begin
	CLK_TB_TX		  = 1'b0   ;
	Prescale_TB		  = 6'd16   ;
	RX_IN_TB		  = 1'b1   ;
	CLK_TB            = 1'b1   ;
	RST_TB            = 1'b1   ;    // rst is deactivated
	PAR_EN_TB  		  = 1'b0   ;
	PAR_TYP_TB     	  = 1'b0   ;
	
  end
endtask


///////////////////////// RESET /////////////////////////
task reset ;
  begin
	#(CLOCK_PERIOD_RX)
	RST_TB  = 'b0;           // rst is activated
	#(CLOCK_PERIOD_RX)
	RST_TB  = 'b1;
	#(CLOCK_PERIOD_RX) ;
  end
endtask

///////////////////// Configuration ////////////////////
task UART_CONFG ;
  input                   PAR_EN ;
  input                   PAR_TYP ;
  //input					  Prescale;

  begin
	PAR_EN_TB     = PAR_EN   ;
	PAR_TYP_TB    = PAR_TYP  ;
	//Prescale_TB   = Prescale ;
  end
endtask


//////////////////  Check Output  ////////////////////
task chk_tx_out ;
 input  [DATA_WD_TB-1:0]  		DATA    ;
 input  [2:0]                   Test_NUM;
 
 begin	
		if (P_DATA_TB == DATA) 
		begin
			$display("Test Case %d is succeeded",Test_NUM);
		end
	else
		begin
			$display("Test Case %d is failed", Test_NUM);
		end
 end
endtask

/////////////// CLK_RX Generator /////////////////////////

always #(CLOCK_PERIOD_RX/2.0000) CLK_TB = ~CLK_TB ;

/////////////// CLK_TX Generator /////////////////////////

always #(CLOCK_PERIOD_TX/2.0000) CLK_TB_TX = ~CLK_TB_TX ;

/////////////////////////////////////////////////
/////////////// DUT Instantation ///////////////
///////////////////////////////////////////////

UART_RX  DUT
(
.RX_IN 			(RX_IN_TB),
.PAR_EN 		(PAR_EN_TB),
.PAR_TYP 		(PAR_TYP_TB),
.Prescale 		(Prescale_TB),
.CLK 			(CLK_TB),
.RST 			(RST_TB),
.P_DATA 		(P_DATA_TB),
.data_valid 	(data_valid_TB)
);

endmodule













 //#193
 /*wait(data_valid_TB)
 #(12*CLOCK_PERIOD_RX);
 RX_IN_TB=0;
 #CLOCK_PERIOD_TX ;
  RX_IN_TB=0;
 #CLOCK_PERIOD_TX ;
  RX_IN_TB=0;
 #CLOCK_PERIOD_TX ;
  RX_IN_TB=0;
 #CLOCK_PERIOD_TX ;
  RX_IN_TB=0;
 #CLOCK_PERIOD_TX ;
  RX_IN_TB=1;
 #CLOCK_PERIOD_TX ;
  RX_IN_TB=1;
 #CLOCK_PERIOD_TX ;
  RX_IN_TB=1;
 #CLOCK_PERIOD_TX ;
  RX_IN_TB=1;
 #CLOCK_PERIOD_TX ;
   RX_IN_TB=0;
 #CLOCK_PERIOD_TX ;
   RX_IN_TB=1;
 #CLOCK_PERIOD_TX ;
 */
 //TX_OUT('b10111100000);  // 1 0 1111 0000 0
 