module neuron_spike_out (
    // Wishbone slave interface
    input clk_i,            // Clock
    input rst_i,            // Reset
    input en_i,             // Enable
    input we_i,             // Determines read or write operation
    input addr_i,           // Address input
    input [31:0] d_i,       // Data input for writes
    output reg [31:0] d_o,  // Data output 

    // External spike data inputs
    input [31:0] external_spike_data_i,
    input external_write_en_i
);

reg [31:0] sram;                      // SRAM storage for spikes (single word now)
reg [31:0] data_next;
reg ram_write;



// Handling read/write operations, the acknowledgment signal, and the external spike update
always @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
        d_o <= 32'b0;
        ram_write <= 0;
        data_next <= 0;
    end
    else if (en_i & (!addr_i)) begin
        if (we_i) begin
            ram_write <= 1;
            data_next <= d_i;
        end
        else d_o <= sram;
    end 
end

always @(external_write_en_i, ram_write) begin
    if(external_write_en_i) sram = external_spike_data_i;
    else if (ram_write) sram = data_next;
end
    
endmodule
