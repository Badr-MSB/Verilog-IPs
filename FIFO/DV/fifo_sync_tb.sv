`define CLK_PERIOD 10

module fifo_sync_tb;

    localparam DataWidth = 4;
    localparam Depth = 8;

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
    
    fifo_sync #(
    .DataWidth(DataWidth),
    .Depth(Depth)
    ) fifo_sync_UT (
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
        $dumpfile("fifo_dump.vcd");
        $dumpvars();
        
        clk = 0;
        reset = 1;
        wvalid_i = 0;
        data_i = 0;
        rready_i = 0;

        #20;
        reset = 0;
        @(posedge clk);

        repeat (Depth) begin
            write($urandom_range(0, 255)[DataWidth-1:0]);
        end
        
        @(posedge clk); 
        #1
        assert (is_full_o == 1'b1) $display("Assert passed");
        else $error("Unexpected behaviour");

        repeat (Depth) begin
            read();
        end

        #100;
        $finish;
    end

    always  #`CLK_PERIOD clk = ~clk;

    always @(is_full_o) begin
        if(is_full_o) begin
            $display("The fifo is full.");
        end
    end

    always @(is_empty_o) begin
        if(is_empty_o) begin
            $display("The fifo is empty.");
        end
    end
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
