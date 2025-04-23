module dma_top #(
    parameter int DataWidth = 8,
) ( 
    input logic clock_i,
    input logic reset_i,
    input logic [64 : 0] src_i,
    input logic [64 : 0] dest_i,
    input logic [16 : 0] size_i,
    output logic dma_done_o
);

endmodule