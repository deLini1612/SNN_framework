module choose_weight
(
    input clk_i,              // Clock
    input en_i,               // Enable
    input we_i,               // Determines read or write operation
    input [3:0] addr_i,       // Address input
    input [31:0] d_i,        // Data input for writes
    output reg [31:0] d_o,   // Data output

    input send_spike_i,
    input [7:0] axon_ind_i,
    output [1:0] weight_type_o
);

reg [31:0] sram [15:0];

// Handling read/write operations and the acknowledgment signal
always @(posedge clk_i) begin
    if (en_i & we_i) begin
        sram[addr_i] <= d_i;
    end
    d_o <= 0;
end


assign weight_type_o = (send_spike_i) ? 
  sram[axon_ind_i[7:4]][30-axon_ind_i[3:0]*2+:2] : 2'b0;


endmodule