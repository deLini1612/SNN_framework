module synapse_matrix (
    // Wishbone slave interface
    input clk_i,            // Clock
    input en_i,             // Enable
    input we_i,             // Determines read or write operation
    input [7:0] addr_i,     // Address input
    input [31:0] d_i,       // Data input for writes
    output [31:0] d_o,  // Data output (not used in this module)

    // Synapse matrix specific output
    output [31:0] neurons_connections_o  // Represents connections of an axon with 32 neurons
);


DFFRAM256x32 sram (
    `ifdef USE_POWER_PINS
    .VPWR (VPWR),    // User area 1 1.8V supply
    .VGND (VGND),    // User area 1 digital ground
    `endif

    .CLK(clk_i),
    .WE0({we_i, we_i, we_i, we_i}),
    .EN0(en_i),
    .Di0(d_i),
    .Do0(d_o),
    .A0(addr_i) 
);

// Generating the connections based on the input address during read operations
// Outputs all zeros when there's a write operation or an invalid Wishbone transaction

reg we_i_ff, en_i_ff;

always @(posedge clk_i) begin
    we_i_ff <= we_i;
    en_i_ff <= en_i;
end

assign neurons_connections_o = (!we_i_ff && en_i_ff) ? 
            d_o : 32'b0;


endmodule
