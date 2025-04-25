module fifo_tb;

    localparam DataWidth = 8;
    localparam Depth = 16;


    // input regs
    reg clk;
    reg reset;
    reg wvalid_i;
    reg [DataWidth-1 : 0] data_i;
    reg rready_i;
    // output wire
    wire wready_o;
    wire rvalid_o;
    wire [DataWidth-1 : 0] data_o;
    wire is_full_o;
    wire is_empty_o;
    
    fifo #(
    .DataWidth(DataWidth),
    .Depth(Depth)
    ) fifo_UT (
    .clk_i(clk),
    .reset_i(reset),
    .wvalid_i(wvalid_i),
    .wready_o(wready_o),
    .data_i(data_i),
    .rready_i(rready_i),
    .rvalid_o(rvalid_o),
    .data_o(data_o),
    .is_full_o(is_full_o),
    .is_empty_o(is_empty_o)
    );

    initial begin
        clk = 0;
        reset = 1;
        wvalid_i = 0;
        data_i = 0;
        rready_i = 0;

        #20;
        reset = 0;
        @(posedge clk);

        repeat (5) begin
            write($urandom_range(0, 255)[DataWidth-1:0]);
        end

        repeat (5) begin
            read();
        end

        #100;
        $finish;
    end

    always  #10 clk = ~clk;

    // task write
    task automatic write(logic [DataWidth-1 : 0] data);
        // Wait until ready
        @(posedge clk);
        while (!wready_o) @(posedge clk);
        
        wvalid_i = 1;
        data_i = data;

        @(posedge clk);

        wvalid_i = 0;
        $display("Data in : %0d", data);
    endtask

    // task read
    task automatic read();
        @(posedge clk);
        while (!rvalid_o) @(posedge clk);

        rready_i = 1;

        @(posedge clk);

        rready_i = 0;
        $display("Data out : %0d", data_o);
    endtask

endmodule