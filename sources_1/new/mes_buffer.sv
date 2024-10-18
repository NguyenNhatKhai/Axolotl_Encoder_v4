////////////////////////////////////////////////////////////////////////////////////////////////////

`include "encoder.vh"

////////////////////////////////////////////////////////////////////////////////////////////////////

module enc_mes_buffer (
    input clk,
    input rst_n,
    input con_stall,
    input [ENC_SYM - 1 : 0][EGF_DIM - 1 : 0] gen_data,
    output logic [ENC_MES_BUF_DEP - 1 : 0][EGF_DIM - 1 : 0] mes_buf_data
);

////////////////////////////////////////////////////////////////////////////////////////////////////

    generate
        for (genvar i = ENC_MES_BUF_DEP - 1; i >= 0; i --) begin
            always_ff @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                    mes_buf_data[i] <= '0;
                end else if (!con_stall) begin
                    if (i < ENC_SYM) begin
                        mes_buf_data[i] <= gen_data[i];
                    end else begin
                        mes_buf_data[i] <= mes_buf_data[i - ENC_SYM];
                    end
                end
            end
        end
    endgenerate

endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////