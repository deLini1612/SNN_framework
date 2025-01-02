// Memory map
// synapse_matrix:  0   - 255
// param0:          256 - 259
// param1:          260 - 263
// ...
// param31:         380 - 383
// spike_out:       384


module slice_decoder (
    input [8:0] addr_i,
    input en_i,
    output reg synap_matrix_o,
    output reg [4:0] param_num_o,
    output reg spike_out_o,
    output reg param_o
);

    always @(addr_i) begin
        // Default outputs to 0
        synap_matrix_o = 0;
        param_o = 0;
        param_num_o = 5'b0;
        spike_out_o = 0;

        if (en_i) begin
            // Decode based on addr_i[8:7]
            if(addr_i[8])begin
                if (addr_i[7]) begin
                    if (!(addr_i[6]|addr_i[5]|addr_i[4]|addr_i[3]|addr_i[2]|addr_i[1]|addr_i[0])) spike_out_o = 1;
                end
                else begin
                    param_o = 1;
                    param_num_o = addr_i[6:2];
                end
            end
            else synap_matrix_o = 1;    
        end
    end

endmodule
