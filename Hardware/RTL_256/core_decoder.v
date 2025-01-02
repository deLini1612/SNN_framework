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

module core_decoder # (
    parameter NUM_OF_SLICE = 8,
    parameter DONE_PIC_ADDR = 448
)
(
    input [11:0] addr_i,
    input we_i,
    input en_i,
    output reg [NUM_OF_SLICE-1:0] slice_o,
    output reg choose_weight_o,
    output reg done_pic_o,
    output reg send_spike_o
);

    always @(addr_i) begin
        // Default outputs to 0
        slice_o = 0;
        send_spike_o = 0;
        choose_weight_o = 0;
        done_pic_o = 0;

        if (en_i) begin
            // Decode based on addr_i[11:9]
            case (addr_i[11:9])
                0: begin
                    // write to choose_weight_o and done_pic_o
                    if (addr_i[8] && addr_i[7] && addr_i[6]) begin
                        if (!(addr_i[5]|addr_i[4]|addr_i[3]|addr_i[2]|addr_i[1]|addr_i[0])) begin
                            done_pic_o = 1;
                            slice_o = 8'b11111111;
                        end
                        else choose_weight_o = addr_i[4];
                    end

                    else begin
                        if (we_i || addr_i[8]) begin
                            slice_o[0] = 1;
                        end
                        else begin 
                            slice_o = 8'b11111111;
                            send_spike_o = 1;
                        end
                    end
                end

                1: begin
                    slice_o[1] = 1;
                end

                2: begin
                    slice_o[2] = 1;
                end

                3: begin
                    slice_o[3] = 1;
                end

                4: begin
                    slice_o[4] = 1;
                end

                5: begin
                    slice_o[5] = 1;
                end

                6: begin
                    slice_o[6] = 1;
                end

                7: begin
                    slice_o[7] = 1;
                end

            endcase            
        end
    end

endmodule
