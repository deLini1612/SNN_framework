/**
 *  Module: neuron_slice
 *  
 *  Overview:
 *  The `neuron_slice` represent a 256x32 SNN core 
 *  
 *  Author: Nguyen Phuong Linh EDABK
 *  Date: May 2024
 */

// Memory map
// synapse_matrix: 0x3000_0000 - 0x3000_03FF
// param0:         0x3000_0400 - 0x3000_040B
// ...
// param31:        0x3000_05F0 - 0x3000_05FB
// spike_out:      0x3000_0600 - 0x3000_0603

module neuron_slice
(
    input  wire clk_i,
    input  wire rst_i,
    input done_pic_i,
    input [1:0] weight_type_i,

    input  wire en_i,
    input  wire we_i,
    input  wire [8:0] addr_i,
    input  wire [31:0] d_i,
    output wire [31:0] d_o
);

    wire synap_matrix_select;
    wire param_select;
    wire [4:0] param_num; // Change to 5 bits for 32 neuron selection
    wire spike_out_select;
    wire [31:0] neurons_connections; // Width changed to 32
    wire [31:0] spike_out; // Width changed to 32
    wire external_write_en;
    wire [31:0] spike_slice;

    slice_decoder slice_decoder (
        .addr_i(addr_i),
        .en_i(en_i),
        .synap_matrix_o(synap_matrix_select),
        .param_o(param_select),
        .param_num_o(param_num),
        .spike_out_o(spike_out_select)
    );

     synapse_matrix sm (
         .clk_i(clk_i),
         .en_i(synap_matrix_select),
         .we_i(we_i),
         .addr_i(addr_i[7:0]),
         .d_i(d_i),
         .neurons_connections_o(neurons_connections)
     );


    neuron_instance neuron_32 (
        .clk_i(clk_i),
        .param_select(param_select),
        .param_num(param_num),
        .we_i(we_i),
        .addr_i(addr_i[1:0]),
        .d_i(d_i),

        .done_pic_i(done_pic_i),
        .weight_type_i(weight_type_i),
        .neurons_connections(neurons_connections),
        .spike_out(spike_out)
    );

    // generate
    //     genvar i;
    //     for (i = 0; i < 32; i = i + 1) begin : neuron_instances
    //         // wires for interfacing neuron_parameters and neuron_block
    //         wire [7:0] voltage_potential, pos_threshold, neg_threshold, leak_value;
    //         wire [7:0] weight_type1, weight_type2, weight_type3, weight_type4;
    //         wire [7:0] pos_reset, neg_reset;
    //         wire [7:0] new_potential;

    //         neuron_parameters np_inst (
    //             .clk_i(clk_i),
    //             .en_i(param_select & (param_num == i)),
    //             .we_i(we_i),
    //             .addr_i(addr_i[1:0]),
    //             .d_i(d_i),

    //             .ext_voltage_potential_i(new_potential),
    //             .ext_write_enable_i(neurons_connections[31-i]),

    //             .voltage_potential_o(voltage_potential),
    //             .pos_threshold_o(pos_threshold),
    //             .neg_threshold_o(neg_threshold),
    //             .leak_value_o(leak_value),
    //             .weight_type1_o(weight_type1),
    //             .weight_type2_o(weight_type2),
    //             .weight_type3_o(weight_type3),
    //             .weight_type4_o(weight_type4),
    //             .pos_reset_o(pos_reset),
    //             .neg_reset_o(neg_reset)
    //         );
                        

    //         neuron_block nb_inst (
    //             .voltage_potential_i(voltage_potential),
    //             .pos_threshold_i(pos_threshold),
    //             .neg_threshold_i(neg_threshold),
    //             .leak_value_i(leak_value),
    //             .weight_type1_i(weight_type1),
    //             .weight_type2_i(weight_type2),
    //             .weight_type3_i(weight_type3),
    //             .weight_type4_i(weight_type4),
    //             .weight_select_i(weight_type_i),
    //             .pos_reset_i(pos_reset),
    //             .neg_reset_i(neg_reset),
    //             .new_potential_o(new_potential),
    //             .enable_i(neurons_connections[31-i]),
    //             .done_pic_i(done_pic_i),
    //             .spike_o(spike_out[31-i])
    //         );
    //     end
    // endgenerate

    assign external_write_en = |spike_out;

    neuron_spike_out spike_out_inst (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .en_i(spike_out_select),
        .we_i(we_i),
        .addr_i(addr_i[0]),
        .d_i(d_i),
        .d_o(spike_slice),
        .external_spike_data_i(spike_out),
        .external_write_en_i(external_write_en)
    );

    // Conditional assignment for the d_o output
    assign d_o = spike_out_select ? spike_slice : 0;

endmodule
