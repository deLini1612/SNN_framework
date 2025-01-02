module neuron_instance (
    input  		clk_i,
    input  		param_select,
    input [4:0] param_num,
    input  		we_i,
    input [1:0] addr_i,
    input  [31:0]		d_i,

    input 		  done_pic_i,
    input [1:0] weight_type_i,
    input  [31:0] neurons_connections,
    output [31:0] spike_out
);

    generate
        genvar i;
        for (i = 0; i < 32; i = i + 1) begin : neuron_instances
            // wires for interfacing neuron_parameters and neuron_block
            wire [7:0] voltage_potential, pos_threshold, neg_threshold, leak_value;
            wire [7:0] weight_type1, weight_type2, weight_type3, weight_type4;
            wire [7:0] pos_reset, neg_reset;
            wire [7:0] new_potential;

            neuron_parameters np_inst (
                .clk_i(clk_i),
                .en_i(param_select & (param_num == i)),
                .we_i(we_i),
                .addr_i(addr_i),
                .d_i(d_i),

                .ext_voltage_potential_i(new_potential),
                .ext_write_enable_i(neurons_connections[31-i]),

                .voltage_potential_o(voltage_potential),
                .pos_threshold_o(pos_threshold),
                .neg_threshold_o(neg_threshold),
                .leak_value_o(leak_value),
                .weight_type1_o(weight_type1),
                .weight_type2_o(weight_type2),
                .weight_type3_o(weight_type3),
                .weight_type4_o(weight_type4),
                .pos_reset_o(pos_reset),
                .neg_reset_o(neg_reset)
            );
                        

            neuron_block nb_inst (
                .voltage_potential_i(voltage_potential),
                .pos_threshold_i(pos_threshold),
                .neg_threshold_i(neg_threshold),
                .leak_value_i(leak_value),
                .weight_type1_i(weight_type1),
                .weight_type2_i(weight_type2),
                .weight_type3_i(weight_type3),
                .weight_type4_i(weight_type4),
                .weight_select_i(weight_type_i),
                .pos_reset_i(pos_reset),
                .neg_reset_i(neg_reset),
                .new_potential_o(new_potential),
                .enable_i(neurons_connections[31-i]),
                .done_pic_i(done_pic_i),
                .spike_o(spike_out[31-i])
            );
        end
    endgenerate

endmodule : neuron_instance
