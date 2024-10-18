////////////////////////////////////////////////////////////////////////////////////////////////////

`include "encoder.vh"

////////////////////////////////////////////////////////////////////////////////////////////////////

module enc_selector (
    input clk,
    input rst_n,
    input SEL_PHASE sel_phase,
    input [$clog2(ENC_SYM + 1) - 1 : 0] sel_request,
    input [$clog2(ENC_MES_BUF_DEP + 1) - 1 : 0] sel_mes_offset,
    input [$clog2(ENC_PAR_BUF_DEP + 1) - 1 : 0] sel_par_offset,
    input [RSC_PAR_LEN - 1 : 0][EGF_DIM - 1 : 0] pro_data,
    input [ENC_MES_BUF_DEP - 1 : 0][EGF_DIM - 1 : 0] mes_buf_data,
    input [ENC_PAR_BUF_DEP - 1 : 0][EGF_DIM - 1 : 0] par_buf_data,
    output logic [ENC_SYM - 1 : 0][EGF_DIM - 1 : 0] sel_data
);

    logic [ENC_SYM - 1 : 0][EGF_DIM - 1 : 0] sel_data_new;

////////////////////////////////////////////////////////////////////////////////////////////////////

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sel_data <= '0;
        end else begin
            sel_data <= sel_data_new;
        end
    end

    always_comb begin
        for (int i = ENC_SYM - 1; i >= 0; i --) begin
            if (sel_phase == SEL_MES && i >= ENC_SYM - sel_request) begin
                sel_data_new[i] = mes_buf_data[i + sel_mes_offset + sel_request - ENC_SYM];
            end else if (sel_phase == SEL_MES) begin
                sel_data_new[i] = pro_data[i + sel_par_offset];
            end else if (sel_phase == SEL_PAR && i >= sel_request) begin
                sel_data_new[i] = par_buf_data[i + sel_par_offset - sel_request];
            end else begin
                sel_data_new[i] = mes_buf_data[i + sel_mes_offset];
            end
        end
    end

endmodule
    
////////////////////////////////////////////////////////////////////////////////////////////////////