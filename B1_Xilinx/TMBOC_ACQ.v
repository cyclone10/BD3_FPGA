`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:11:47 11/07/2015 
// Design Name: 	whc
// Module Name:    TMBOC_ACQ
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module TMBOC_ACQ(rx_clk,rx_rst,rx_src,rx_car_fcw,rx_prn_fcw,
				tx_src_real,tx_src_imag,tx_prn_sop,tx_trk_rst,
				tx_loc_tmbocE,tx_loc_tmbocP,tx_loc_tmbocL,tx_prn_sop,
				prn_phs,tx_car_nco,tx_prn_nco);

parameter ACC_WIDTH = 32;
parameter CORR_WIDTH = 32;
parameter PRN_PHS_WIDTH = 14;
input[7:0] rx_src;
input rx_clk,rx_rst;
input[ACC_WIDTH-1:0] rx_prn_fcw,rx_car_fcw;
output[15:0] tx_src_real;
output[15:0] tx_src_imag;
output tx_loc_tmbocE,tx_loc_tmbocP,tx_loc_tmbocL;
output tx_prn_sop;
output tx_trk_rst;
output[31:0] tx_car_nco,tx_prn_nco;
output[11:0] prn_phs;

<<<<<<< HEAD
=======

reg acq_flag;
reg acq_suc;
reg[PRN_PHS_WIDTH-1:0] acq_phs;
wire[PRN_PHS_WIDTH-1:0] prn_phs;
assign tx_trk_rst = rx_rst | (acq_flag ^ acq_suc);
>>>>>>> origin/master

wire[11:0] prn_phs;
wire[31:0] car_fcw,prn_fcw;
assign car_fcw = 32'd1975684956 - rx_car_fcw;//35420000Hz
assign prn_fcw = {rx_prn_fcw[29:0],2'b0}+32'd228246833;

<<<<<<< HEAD

wire loc_tmboc;
TMBOC_PRN_GEN_TRK TMBOC_PRN_GEN_TRK(.rx_clk(rx_clk),.rx_rst(rx_rst),.rx_prn_fcw(prn_fcw),.rx_corr_paral(3'b0),.rx_init_phs({ACC_WIDTH{1'b0}}),
						.tx_loc_tmboc(loc_tmboc),.tx_loc_prn(),.tx_prn_sop(tx_prn_sop),.tx_prn_eop(prn_eop),.tx_prn_phs(prn_phs),
						.tx_phs_acc_reg(tx_prn_nco));
=======
reg trk_rst;
reg prn_gen_rst;
always @(posedge rx_clk) begin
	if(rx_rst) begin
		prn_gen_rst <= 1'b1;
		acq_suc <= 1'b0;
	end
	else begin
		if(acq_flag && !acq_suc) begin 
			if(prn_phs == acq_phs) begin
				prn_gen_rst <= 1'b1;
				acq_suc <= 1'b1;
			end
			else
				prn_gen_rst <= 1'b0;
		end
		else
			prn_gen_rst <= 1'b0;
	end
end


TMBOC_PRN_GEN_TRK TMBOC_PRN_GEN_TRK(.rx_clk(rx_clk),.rx_rst(prn_gen_rst),.rx_prn_fcw(prn_fcw),.rx_corr_paral(3'b0),.rx_init_phs({ACC_WIDTH{1'b0}}),
						.tx_loc_tmboc(tx_tmloc_bocE),.tx_loc_prn(),.tx_prn_sop(tx_prn_sop),.tx_prn_eop(prn_eop),.tx_prn_phs(prn_phs));
>>>>>>> origin/master

reg prn_phs_delay;
reg tx_loc_tmbocE,tx_loc_tmbocP,tx_loc_tmbocL;
always @(posedge rx_clk) begin
	if(rx_rst) begin
		tx_loc_tmbocE <= 1'b0;
		tx_loc_tmbocP <= 1'b0;
		tx_loc_tmbocL <= 1'b0;
		prn_phs_delay <= 1'b0;
	end
	else begin
		if(prn_phs_delay ^ prn_phs[0]) begin
			tx_loc_tmbocE <= loc_tmboc;
			tx_loc_tmbocL <= tx_loc_tmbocP;
			tx_loc_tmbocP <= tx_loc_tmbocE;
		end		
		prn_phs_delay <= prn_phs[0];
	end
end

wire[7:0] car_cos,car_sin;
wire[15:0] data_real,data_imag;
assign tx_src_real = data_real;
assign tx_src_imag = data_imag;
CAR_GEN TMBOC_CAR_GEN(.rx_clk(rx_clk),.rx_rst(rx_rst),.rx_car_fcw(car_fcw),
					.tx_car_cos(car_cos),.tx_car_sin(car_sin),.phs_acc_reg(tx_car_nco));	
				
<<<<<<< HEAD
LPM_MULT8_CORE multiI(	.clk(rx_clk),	.a(car_cos),	.b(rx_src),	.p(data_real));
LPM_MULT8_CORE multiQ(	.clk(rx_clk),	.a(car_sin),	.b(rx_src),	.p(data_imag));
=======
TMBOC_PRN_GEN_ACQ TMBOC_PRN_GEN_U1(.rx_clk(rx_clk),.rx_rst(rx_rst),.rx_prn_fcw(prn_fcw),.rx_corr_paral(3'b100),.rx_init_phs({ACC_WIDTH{1'b0}}),.rx_paral_index(2'b00),
						.tx_loc_tmboc(loc_tmboc_1),.tx_loc_prn(),.tx_prn_sop(prn_sop_1),.tx_prn_eop(prn_eop_1));
TMBOC_PRN_GEN_ACQ TMBOC_PRN_GEN_U2(.rx_clk(rx_clk),.rx_rst(rx_rst),.rx_prn_fcw(prn_fcw),.rx_corr_paral(3'b100),.rx_init_phs({2'b01,{{ACC_WIDTH-2}{1'b0}}}),.rx_paral_index(2'b01),
						.tx_loc_tmboc(loc_tmboc_2),.tx_loc_prn(),.tx_prn_sop(prn_sop_2),.tx_prn_eop(prn_eop_2));
TMBOC_PRN_GEN_ACQ TMBOC_PRN_GEN_U3(.rx_clk(rx_clk),.rx_rst(rx_rst),.rx_prn_fcw(prn_fcw),.rx_corr_paral(3'b100),.rx_init_phs({2'b10,{{ACC_WIDTH-2}{1'b0}}}),.rx_paral_index(2'b10),
						.tx_loc_tmboc(loc_tmboc_3),.tx_loc_prn(),.tx_prn_sop(prn_sop_3),.tx_prn_eop(prn_eop_3));	
TMBOC_PRN_GEN_ACQ TMBOC_PRN_GEN_U4(.rx_clk(rx_clk),.rx_rst(rx_rst),.rx_prn_fcw(prn_fcw),.rx_corr_paral(3'b100),.rx_init_phs({2'b11,{{ACC_WIDTH-2}{1'b0}}}),.rx_paral_index(2'b11),
						.tx_loc_tmboc(loc_tmboc_4),.tx_loc_prn(),.tx_prn_sop(prn_sop_4),.tx_prn_eop(prn_eop_4));							

LPM_MULT8_CORE multiI(	.a(car_cos),	.b(rx_src),	.p(data_real));
LPM_MULT8_CORE multiQ(	.a(car_sin),	.b(rx_src),	.p(data_imag));
>>>>>>> origin/master


<<<<<<< HEAD
=======
reg[CORR_WIDTH-1:0] corr_peak;
reg[PRN_PHS_WIDTH-1:0] acq_prn_phs; 
reg[PRN_PHS_WIDTH-1:0] corr_phs_1,corr_phs_2,corr_phs_3,corr_phs_4;
always @(posedge rx_clk) begin
	if(rx_rst) begin
		corr_peak <= {CORR_WIDTH{1'b0}};
		acq_prn_phs <= {PRN_PHS_WIDTH{1'b0}};
		corr_phs_1 <= {{{PRN_PHS_WIDTH-2}{1'b0}},2'b00};
		corr_phs_2 <= {{{PRN_PHS_WIDTH-2}{1'b0}},2'b01};
		corr_phs_3 <= {{{PRN_PHS_WIDTH-2}{1'b0}},2'b10};
		corr_phs_4 <= {{{PRN_PHS_WIDTH-2}{1'b0}},2'b11};
	end
	else if(!acq_suc) begin
		if(prn_eop_1) begin
			if(corr_acc_1 > corr_peak) begin
				corr_peak <= corr_acc_1;
				acq_prn_phs <= corr_phs_1;
			end
			corr_phs_1 <= corr_phs_1 + 4;
		end
		
		if(prn_eop_2) begin
			if(corr_acc_2 > corr_peak) begin
				corr_peak <= corr_acc_2;
				acq_prn_phs <= corr_phs_2;
			end
			corr_phs_2 <= corr_phs_2 + 4;
		end
		
		if(prn_eop_3) begin
			if(corr_acc_3 > corr_peak) begin
				corr_peak <= corr_acc_3;
				acq_prn_phs <= corr_phs_3;
			end
			corr_phs_3 <= corr_phs_3 + 4;
		end
		
		if(prn_eop_4) begin
			if(corr_acc_4 > corr_peak) begin
				corr_peak <= corr_acc_4;
				acq_prn_phs <= corr_phs_4;
			end
			corr_phs_4 <= corr_phs_4 + 4;
		end
	end
end



always @(posedge rx_clk) begin
	if(rx_rst) begin
		acq_flag <= 1'b0;
		acq_phs <= {PRN_PHS_WIDTH{1'b0}};
	end
	else begin
		if(corr_phs_4==14'd8184) begin
			acq_flag <= 1'b1;
			acq_phs <= acq_prn_phs;
		end
	end
end
>>>>>>> origin/master

endmodule