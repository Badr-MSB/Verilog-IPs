module fifo #(
    parameter int unsigned DataWidth = 8,
    parameter int unsigned Depth = 16
) (
    //
    input  logic clk_i,
    input  logic reset_i,

    //write
    input  logic wvalid_i,
    output logic wready_o,
    input  logic [DataWidth-1 : 0] data_i,
    
    // read
    input  logic rready_i,
    output logic rvalid_o,
    output logic [DataWidth-1 : 0] data_o,

    // full & empty
    output logic is_full_o,
    output logic is_empty_o
);

    logic [DataWidth-1:0] file [Depth-1:0];

    int read_ptr;
    int write_ptr;
    int count;

    // write
    always @(posedge clk_i) begin
        if(reset_i) begin
            write_ptr <= 0;
            count <= 0;
        end
        else begin
            if(wvalid_i & wready_o) begin
                file[write_ptr] <= data_i;
                write_ptr <= write_ptr + 1;
                count <= count + 1;
            end
        end
    end

    // read
    always @(posedge clk_i) begin
        if( reset_i )begin
            read_ptr <= 0;
            data_o <= '0;
            count <= 0;
        end
        else begin
            if (rready_i & rvalid_o) begin
                data_o <= file[read_ptr];
                read_ptr <= read_ptr + 1;
                count <= count - 1;
            end
        end
    end

    // full & empty
    assign is_full_o  = (count == Depth);
    assign is_empty_o = (count == 0);

    assign rvalid_o = (count > 0);
    assign wready_o = (count < Depth);

endmodule
