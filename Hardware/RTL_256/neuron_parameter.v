module neuron_parameters (
    // Wishbone slave interface
    input clk_i,            // Clock
    input en_i,             // Enable
    input we_i,             // Determines read or write operation
    input [1:0] addr_i,     // Address input
    input [31:0] d_i,       // Data input for writes
    output reg [31:0] d_o,  // Data output
    
    // New inputs for external write to voltage_potential_o
    input [7:0] ext_voltage_potential_i, // External voltage potential input
    input ext_write_enable_i,            // External write enable signal

    // Neuron-specific outputs
    output [7:0] voltage_potential_o, // Current voltage potential
    output [7:0] pos_threshold_o,     // Positive threshold
    output [7:0] neg_threshold_o,     // Negative threshold
    output [7:0] leak_value_o,        // Leak value
    output [7:0] weight_type1_o,      // 1st weight type
    output [7:0] weight_type2_o,      // 2nd weight type
    output [7:0] weight_type3_o,      // 3rd weight type
    output [7:0] weight_type4_o,      // 4th weight type
    output [7:0] pos_reset_o,         // Positive reset
    output [7:0] neg_reset_o          // Negative reset
);

reg [31:0] sram [2:0];               // SRAM storage

// Handling read/write operations and the acknowledgment signal
always @(posedge clk_i) begin
    if (en_i & (!(&addr_i)) & we_i) begin
        sram[addr_i] <= d_i;
    end

    else begin    
        // New logic for external write to voltage_potential_o
        if (ext_write_enable_i) begin
            sram[2][31:24] <= ext_voltage_potential_i;
        end
    end

    d_o <= 0;
end

assign voltage_potential_o = sram[2][31:24];
assign pos_threshold_o = sram[2][23:16];
assign neg_threshold_o = sram[2][15:8];
assign leak_value_o = sram[2][7:0];
assign weight_type1_o = sram[1][31:24];
assign weight_type2_o = sram[1][23:16];
assign weight_type3_o = sram[1][15:8];
assign weight_type4_o = sram[1][7:0];
assign pos_reset_o = sram[0][31:24];
assign neg_reset_o = sram[0][23:16];

endmodule
