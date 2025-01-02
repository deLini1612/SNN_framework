/**
 *  Module: neuron_core
 *  
 *  Overview:
 *  The `neuron_core` includes 8 slice to represent a 256x256 SNN core 
 *  
 *  Author: Nguyen Phuong Linh (deLini1612) EDABK
 *  Date: May 2024
 */

// Memory map
// slice0:          0       -   511
// slice1:          512     -   1023
// slice2:          1024    -   1535
// slice3:          1536    -   2047
// slice4:          2048    -   2559
// slice5:          2560    -   3071
// slice6:          3072    -   3583
// slice7:          3584    -   4095
// choose_weight:   464     -   479
// done_pic:        448


module neuron_core_256x256
(
    `ifdef USE_POWER_PINS
    inout vssd1,    // User area 1 1.8V supply
    inout vccd1,    // User area 1 digital ground
    `endif
    
    input  wire clk_i,
    input  wire rst_i,
    input  wire en_i,
    input  wire we_i,
    input  wire [11:0] addr_i,
    input  wire [31:0] d_i,
    output wire [31:0] d_o
);

    localparam NUM_OF_SLICE = 8;               // number of cores
    localparam DONE_PIC_ADDR = 448;

    wire done_pic;
    wire send_spike;
    wire choose_weight;
    wire [1:0] weight_type;
    wire [NUM_OF_SLICE-1:0] slice;
    wire [31:0] slave_dat_o [NUM_OF_SLICE - 1:0];
 
    //core decoder for 8 core
    core_decoder core_decoder (
        .addr_i(addr_i),
        .we_i(we_i),
        .en_i(en_i),
        .slice_o(slice),
        .choose_weight_o(choose_weight),
        .done_pic_o(done_pic),
        .send_spike_o(send_spike)
    );

    //choose_weight base on axon number
    choose_weight choose_weight_inst (
        .clk_i(clk_i),
        .en_i(choose_weight),
        .we_i(we_i),
        .addr_i(addr_i[3:0]),
        .d_i(d_i),
        .weight_type_o(weight_type),
        .axon_ind_i(addr_i[7:0]),
        .send_spike_i(send_spike)
    );
    
    reg [1:0] weight_type_ff;
    always @(posedge clk_i) begin
        weight_type_ff <= weight_type;
    end
    generate
        genvar i;
        for (i = 0; i < NUM_OF_SLICE; i=i+1) begin: slice_instances
            neuron_slice neuron_slice_inst (
                .clk_i(clk_i),
                .rst_i(rst_i),
                .done_pic_i(done_pic),
                .weight_type_i(weight_type_ff),

                .en_i(slice[i]),
                .we_i(we_i),
                .addr_i(addr_i[8:0]),
                .d_i(d_i),
                .d_o(slave_dat_o[i]) 
            );
        end
    endgenerate

    reg [NUM_OF_SLICE-1:0] slice_ff;
    always @(posedge clk_i) begin
        slice_ff <= slice;
    end


    // Conditional assignment for the d_o output
    assign d_o =    slice_ff[0] ? slave_dat_o[0] :
                    slice_ff[1] ? slave_dat_o[1] :
                    slice_ff[2] ? slave_dat_o[2] : 
                    slice_ff[3] ? slave_dat_o[3] : 
                    slice_ff[4] ? slave_dat_o[4] : 
                    slice_ff[5] ? slave_dat_o[5] : 
                    slice_ff[6] ? slave_dat_o[6] : 
                    slice_ff[7] ? slave_dat_o[7] :  
                    32'b0;

endmodule

