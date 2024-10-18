////////////////////////////////////////////////////////////////////////////////////////////////////

`include "encoder.vh"

////////////////////////////////////////////////////////////////////////////////////////////////////

module encoder (
    input clk,
    input rst_n,
    input [ENC_SYM * EGF_DIM - 1 : 0] gen_data,
    output logic [ENC_SYM * EGF_DIM - 1 : 0] enc_data
);

    logic [$clog2(RSC_COD_LEN) - 1 : 0] con_counter;
    logic con_stall;
    PRO_PHASE pro_phase;
    logic pro_finish;
    logic [$clog2(ENC_MES_BUF_DEP + 1) - 1 : 0] pro_offset;
    SEL_PHASE sel_phase;
    logic [$clog2(ENC_SYM + 1) - 1 : 0] sel_request;
    logic [$clog2(ENC_MES_BUF_DEP + 1) - 1 : 0] sel_mes_offset;
    logic [$clog2(ENC_PAR_BUF_DEP + 1) - 1 : 0] sel_par_offset;
    
    logic [ENC_MES_BUF_DEP - 1 : 0][EGF_DIM - 1 : 0] mes_buf_data;
    logic [RSC_PAR_LEN - 1 : 0][EGF_DIM - 1 : 0] pro_data;
    logic [ENC_PAR_BUF_DEP - 1 : 0][EGF_DIM - 1 : 0] par_buf_data;
    logic [ENC_SYM - 1 : 0][EGF_DIM - 1 : 0] sel_data;
    
    assign enc_data = sel_data;

////////////////////////////////////////////////////////////////////////////////////////////////////

    enc_controller controller (
        .clk(clk),
        .rst_n(rst_n),
        .con_counter(con_counter),
        .con_stall(con_stall),
        .pro_phase(pro_phase),
        .pro_finish(pro_finish),
        .pro_offset(pro_offset),
        .sel_phase(sel_phase),
        .sel_request(sel_request),
        .sel_mes_offset(sel_mes_offset),
        .sel_par_offset(sel_par_offset)
    );

    enc_mes_buffer mes_buffer (
        .clk(clk),
        .rst_n(rst_n),
        .con_stall(con_stall),
        .gen_data(gen_data),
        .mes_buf_data(mes_buf_data)
    );
    
    enc_processor processor (
        .clk(clk),
        .rst_n(rst_n),
        .pro_phase(pro_phase),
        .pro_offset(pro_offset),
        .mes_buf_data(mes_buf_data),
        .pro_data(pro_data)
    );
    
    enc_par_buffer par_buffer (
        .clk(clk),
        .rst_n(rst_n),
        .pro_finish(pro_finish),
        .pro_data(pro_data),
        .par_buf_data(par_buf_data)
    );
    
    enc_selector selector (
        .clk(clk),
        .rst_n(rst_n),
        .sel_phase(sel_phase),
        .sel_request(sel_request),
        .sel_mes_offset(sel_mes_offset),
        .sel_par_offset(sel_par_offset),
        .pro_data(pro_data),
        .mes_buf_data(mes_buf_data),
        .par_buf_data(par_buf_data),
        .sel_data(sel_data)
    );

endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////