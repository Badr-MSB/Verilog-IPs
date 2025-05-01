// We assume for the moment that the host & device have the same clk

`include "./tlul_pkg.sv"
`include "../FIFO/fifo_async.sv"

module tlul_fifo_async #(
    parameter ReqDepth = 8,
    parameter RspDepth = 8
) (
    //
    input logic clk_i,
    input logic reset_i,
    
    //
    input tlul_pkg::tl_h2d_t tl_h_i,
    input tlul_pkg::tl_d2h_t tl_d_i,

    //
    output tlul_pkg::tl_d2h_t tl_h_o,
    output tlul_pkg::tl_h2d_t tl_d_o

);

    localparam Reqfifo_width = $bits(tlul_pkg::tl_h2d_t)-2; // ready and valid are not pats of the data

    fifo_async #(
        .DataWidth(Reqfifo_width),
        .Depth(ReqDepth)
    ) tl_ch_a (
        .clk_i      (clk_i),
        .reset_i    (reset_i),
        .wvalid_i   (tl_h_i.a_valid),
        .wready_o   (tl_h_o.a_ready),
        .data_i     ({tl_h_i.a_opcode ,
                      tl_h_i.a_param  ,
                      tl_h_i.a_size   ,
                      tl_h_i.a_source ,
                      tl_h_i.a_address,
                      tl_h_i.a_mask   ,
                      tl_h_i.a_data   ,
                      tl_h_i.a_user   }),
        .rready_i   (tl_d_i.a_ready),
        .rvalid_o   (tl_d_o.a_valid),
        .data_o     ({tl_d_o.a_opcode ,
                      tl_d_o.a_param  ,
                      tl_d_o.a_size   ,
                      tl_d_o.a_source ,
                      tl_d_o.a_address,
                      tl_d_o.a_mask   ,
                      tl_d_o.a_data   ,
                      tl_d_o.a_user   }),
        .is_full_o  (),
        .is_empty_o ()
    );
    
    localparam Rspfifo_width = $bits(tlul_pkg::tl_d2h_t)-2; // ready and valid are not pats of the data

    fifo_async #(
        .DataWidth(Rspfifo_width),
        .Depth(RspDepth)
    ) tl_ch_d (
        .clk_i      (clk_i),
        .reset_i    (reset_i),
        .wvalid_i   (tl_d_i.d_valid),
        .wready_o   (tl_d_o.d_ready),
        .data_i     ({tl_d_i.d_opcode,
                     tl_d_i.d_param ,
                     tl_d_i.d_size  ,
                     tl_d_i.d_source,
                     tl_d_i.d_sink  ,
                     tl_d_i.d_data  ,
                     tl_d_i.d_user  ,
                     tl_d_i.d_error }),
        .rready_i   (tl_h_i.d_ready),
        .rvalid_o   (tl_h_o.d_valid),
        .data_o     ({tl_h_o.d_opcode,
                     tl_h_o.d_param ,
                     tl_h_o.d_size  ,
                     tl_h_o.d_source,
                     tl_h_o.d_sink  ,
                     tl_h_o.d_data  ,
                     tl_h_o.d_user  ,
                     tl_h_o.d_error }),
        .is_full_o  (),
        .is_empty_o ()
    );

endmodule
