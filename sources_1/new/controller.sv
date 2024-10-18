////////////////////////////////////////////////////////////////////////////////////////////////////

`include "encoder.vh"

////////////////////////////////////////////////////////////////////////////////////////////////////

module enc_controller (
    input clk,
    input rst_n,
    output logic [$clog2(RSC_COD_LEN) - 1 : 0] con_counter,
    output logic con_stall,
    output PRO_PHASE pro_phase,
    output logic pro_finish,
    output logic [$clog2(ENC_MES_BUF_DEP + 1) - 1 : 0] pro_offset,
    output SEL_PHASE sel_phase,
    output logic [$clog2(ENC_SYM + 1) - 1 : 0] sel_request,
    output logic [$clog2(ENC_MES_BUF_DEP + 1) - 1 : 0] sel_mes_offset,
    output logic [$clog2(ENC_PAR_BUF_DEP + 1) - 1 : 0] sel_par_offset
);

    logic [$clog2(RSC_COD_LEN) - 1 : 0] con_counter_new;
    logic con_stall_new;

    PRO_PHASE pro_phase_new;
    logic pro_finish_new;
    logic [$clog2(ENC_MES_BUF_DEP + 1) - 1 : 0] pro_offset_new;

    SEL_PHASE sel_phase_new;
    logic [$clog2(ENC_SYM + 1) - 1 : 0] sel_request_new;
    logic [$clog2(ENC_MES_BUF_DEP + 1) - 1 : 0] sel_mes_offset_new;
    logic [$clog2(ENC_PAR_BUF_DEP + 1) - 1 : 0] sel_par_offset_new;

    assign con_counter_new = (con_counter > RSC_COD_LEN - ENC_SYM) ? (con_counter + ENC_SYM - RSC_COD_LEN) : (con_counter + ENC_SYM);
    assign pro_finish_new = (con_counter_new >= RSC_MES_LEN) & (con_counter_new < RSC_MES_LEN + ENC_SYM);
    assign sel_par_offset_new = pro_finish_new ? (sel_request_new + RSC_PAR_LEN - ENC_SYM) : (sel_par_offset + sel_request_new - ENC_SYM);

////////////////////////////////////////////////////////////////////////////////////////////////////

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            con_counter <= '0;
            con_stall <= '0;
            pro_phase <= PRO_IDL;
            pro_finish <= '0;
            pro_offset <= '0;
            sel_phase <= SEL_IDL;
            sel_request <= '0;
            sel_mes_offset <= '0;
            sel_par_offset <= '0;
        end else begin
            con_counter <= con_counter_new;
            con_stall <= con_stall_new;
            pro_phase <= pro_phase_new;
            pro_finish <= pro_finish_new;
            pro_offset <= pro_offset_new;
            sel_phase <= sel_phase_new;
            sel_request <= sel_request_new;
            sel_mes_offset <= sel_mes_offset_new;
            sel_par_offset <= sel_par_offset_new;
        end
    end

////////////////////////////////////////////////////////////////////////////////////////////////////

    always_comb begin
        logic [RSC_PAR_LEN - 1 : 0] con_stall_temp;
        for (int i = RSC_PAR_LEN - 1; i >= 0; i --) begin
            con_stall_temp[i] = (con_counter_new == ENC_CON_STA[i]);
        end
        con_stall_new = |con_stall_temp;
    end

////////////////////////////////////////////////////////////////////////////////////////////////////

    always_comb begin
        if (con_counter_new < RSC_MES_LEN % ENC_SYM) begin
            pro_phase_new = PRO_IDL;
        end else if (con_counter_new < ENC_SYM + RSC_MES_LEN % ENC_SYM) begin
            pro_phase_new = PRO_PAR;
        end else if (con_counter_new < RSC_MES_LEN + ENC_SYM) begin
            pro_phase_new = PRO_FUL;
        end else begin
            pro_phase_new = PRO_IDL;
        end
    end

////////////////////////////////////////////////////////////////////////////////////////////////////

    always_comb begin
        if (con_counter_new == ENC_SYM) begin
            pro_offset_new = ENC_SYM - RSC_MES_LEN % ENC_SYM;
        end else begin
            case (pro_phase_new)
                PRO_PAR: pro_offset_new = con_stall ? (pro_offset - RSC_MES_LEN % ENC_SYM) : (pro_offset + ENC_SYM - RSC_MES_LEN % ENC_SYM);
                PRO_FUL: pro_offset_new = con_stall ? (pro_offset - ENC_SYM) : pro_offset;
                default: pro_offset_new = con_stall ? pro_offset : (pro_offset + ENC_SYM);
            endcase
        end
    end

////////////////////////////////////////////////////////////////////////////////////////////////////

    always_comb begin
        if (con_counter_new == '0) begin
            sel_phase_new = SEL_IDL;
        end else if (con_counter_new < ENC_SYM) begin
            sel_phase_new = SEL_PAR;
        end else if (con_counter_new < RSC_MES_LEN + ENC_SYM) begin
            sel_phase_new = SEL_MES;
        end else if (con_counter_new <= RSC_COD_LEN) begin
            sel_phase_new = SEL_PAR;
        end else begin
            sel_phase_new = SEL_IDL;
        end
    end

////////////////////////////////////////////////////////////////////////////////////////////////////

    always_comb begin
        if (con_counter_new == '0) begin
            sel_request_new = '0;
        end else if (con_counter_new < ENC_SYM) begin
            sel_request_new = con_counter_new;
        end else if (con_counter_new <= RSC_MES_LEN) begin
            sel_request_new = ENC_SYM;
        end else if (con_counter_new < RSC_MES_LEN + ENC_SYM) begin
            sel_request_new = RSC_MES_LEN + ENC_SYM - con_counter_new;
        end else begin
            sel_request_new = '0;
        end
    end

////////////////////////////////////////////////////////////////////////////////////////////////////

    always_comb begin
        if (con_counter_new == ENC_SYM) begin
            sel_mes_offset_new = '0;
        end else if (con_stall) begin
            sel_mes_offset_new = sel_mes_offset - sel_request_new;
        end else begin
            sel_mes_offset_new = sel_mes_offset + ENC_SYM - sel_request_new;
        end
    end

endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////