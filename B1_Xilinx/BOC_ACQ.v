`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:11:47 11/07/2015 
// Design Name: 	whc
// Module Name:    BOC_ACQ
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
module BOC_ACQ(rx_clk,rx_rst,rx_src,rx_car_fcw,rx_prn_fcw,
				tx_src_real,tx_src_imag,tx_prn_sop,tx_trk_rst,
				tx_loc_bocE,tx_loc_bocP,tx_loc_bocL,tx_prn_sop);

parameter ACC_WIDTH = 32;
parameter CORR_WIDTH = 32;
parameter PRN_PHS_WIDTH = 12;
input[7:0] rx_src;
input rx_clk,rx_rst;
output[15:0] tx_src_real;
output[15:0] tx_src_imag;
output[ACC_WIDTH-1:0] rx_car_fcw,rx_prn_fcw;

output tx_loc_bocE,tx_loc_bocP,tx_loc_bocL;
output tx_prn_sop;
output tx_trk_rst;

reg acq_suc;
reg acq_flag;
reg[PRN_PHS_WIDTH-1:0] acq_phs;
wire[PRN_PHS_WIDTH-1:0] prn_phs;
assign tx_trk_rst = rx_rst | (acq_flag ^ acq_suc);

assign car_fcw = acq_suc?(32'd1342177280 - rx_car_fcw):32'd1342177280;
assign prn_fcw = acq_suc?(rx_prn_fcw+32'd274609472):32'd274609472;

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

wire tx_loc_bocE;
BOC_PRN_GEN BOC_PRN_GEN_TRK(.rx_clk(rx_clk),.rx_rst(prn_gen_rst),.rx_prn_fcw(prn_fcw),.rx_corr_paral(3'b0),.rx_init_phs({ACC_WIDTH{1'b0}}),
						.tx_loc_boc(tx_loc_bocE),.tx_loc_prn(),.tx_prn_sop(tx_prn_sop),.tx_prn_eop(prn_eop),.tx_prn_phs(prn_phs));

reg prn_phs_delay;
reg tx_loc_bocP,tx_loc_bocL;
always @(posedge rx_clk) begin
	if(rx_rst) begin
		tx_loc_bocP <= 1'b0;
		tx_loc_bocL <= 1'b0;
		prn_phs_delay <= 1'b0;
	end
	else begin
		if(prn_phs_delay ^ prn_phs[0]) begin
			tx_loc_bocL <= tx_loc_bocP;
			tx_loc_bocP <= tx_loc_bocE;
		end		
		prn_phs_delay <= prn_phs[0];
	end
end


wire[15:0] car_cos,car_sin;
assign tx_src_real = car_cos;
assign tx_src_imag = car_sin;
CAR_GEN BOC_CAR_GEN(.rx_clk(rx_clk),.rx_rst(rx_rst),.rx_car_fcw(car_fcw),
					.tx_car_cos(car_cos),.tx_car_sin(car_sin));	
				
BOC_PRN_GEN BOC_PRN_GEN_U1(.rx_clk(rx_clk),.rx_rst(rx_rst),.rx_prn_fcw(prn_fcw),.rx_corr_paral(3'b100),.rx_init_phs({ACC_WIDTH{1'b0}}),.rx_paral_index(2'b00),
						.tx_loc_boc(loc_boc_1),.tx_loc_prn(),.tx_prn_sop(prn_sop_1),.tx_prn_eop(prn_eop_1));
BOC_PRN_GEN BOC_PRN_GEN_U2(.rx_clk(rx_clk),.rx_rst(rx_rst),.rx_prn_fcw(prn_fcw),.rx_corr_paral(3'b100),.rx_init_phs({2'b01,{{ACC_WIDTH-2}{1'b0}}}),.rx_paral_index(2'b01),
						.tx_loc_boc(loc_boc_2),.tx_loc_prn(),.tx_prn_sop(prn_sop_2),.tx_prn_eop(prn_eop_2));
BOC_PRN_GEN BOC_PRN_GEN_U3(.rx_clk(rx_clk),.rx_rst(rx_rst),.rx_prn_fcw(prn_fcw),.rx_corr_paral(3'b100),.rx_init_phs({2'b10,{{ACC_WIDTH-2}{1'b0}}}),.rx_paral_index(2'b10),
						.tx_loc_boc(loc_boc_3),.tx_loc_prn(),.tx_prn_sop(prn_sop_3),.tx_prn_eop(prn_eop_3));	
BOC_PRN_GEN BOC_PRN_GEN_U4(.rx_clk(rx_clk),.rx_rst(rx_rst),.rx_prn_fcw(prn_fcw),.rx_corr_paral(3'b100),.rx_init_phs({2'b11,{{ACC_WIDTH-2}{1'b0}}}),.rx_paral_index(2'b11),
						.tx_loc_boc(loc_boc_4),.tx_loc_prn(),.tx_prn_sop(prn_sop_4),.tx_prn_eop(prn_eop_4));							

LPM_MULT8_CORE multiI(	.a(car_cos),	.b(rx_src),	.p(data_real));
LPM_MULT8_CORE multiQ(	.a(car_sin),	.b(rx_src),	.p(data_imag));

CORR_ACC BOC_CORR_U1(.rx_clk(rx_clk),.rx_rst(rx_rst),.rx_data_real(data_real),.rx_data_imag(data_imag),
				.rx_loc_boc(loc_boc_1),.rx_prn_sop(prn_sop_1),.rx_prn_eop(prn_eop_1),.tx_corr_acc(corr_acc_1));
CORR_ACC BOC_CORR_U2(.rx_clk(rx_clk),.rx_rst(rx_rst),.rx_data_real(data_real),.rx_data_imag(data_imag),
				.rx_loc_boc(loc_boc_2),.rx_prn_sop(prn_sop_2),.rx_prn_eop(prn_eop_2),.tx_corr_acc(corr_acc_2));
CORR_ACC BOC_CORR_U3(.rx_clk(rx_clk),.rx_rst(rx_rst),.rx_data_real(data_real),.rx_data_imag(data_imag),
				.rx_loc_boc(loc_boc_3),.rx_prn_sop(prn_sop_3),.rx_prn_eop(prn_eop_3),.tx_corr_acc(corr_acc_3));
CORR_ACC BOC_CORR_U4(.rx_clk(rx_clk),.rx_rst(rx_rst),.rx_data_real(data_real),.rx_data_imag(data_imag),
				.rx_loc_boc(loc_boc_4),.rx_prn_sop(prn_sop_4),.rx_prn_eop(prn_eop_4),.tx_corr_acc(corr_acc_4));

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
		if(corr_phs_4==12'd4092) begin
			acq_flag <= 1'b1;
			acq_phs <= acq_prn_phs;
		end
	end
end

endmodule