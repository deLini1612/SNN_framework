// Memory map
// slice0:          0       -   511
// choose_weight:   464     -   479
// done_pic:        448

module core_decoder # (
    parameter NUM_OF_SLICE = 1,
    parameter DONE_PIC_ADDR = 448
)
(
    input [8:0] addr_i,
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

            // write to choose_weight_o and done_pic_o
            if (addr_i[8] && addr_i[7] && addr_i[6]) begin
                if (!(addr_i[5]|addr_i[4]|addr_i[3]|addr_i[2]|addr_i[1]|addr_i[0])) begin
                    done_pic_o = 1;
                    slice_o = {NUM_OF_SLICE{1'b1}};
                end
                else choose_weight_o = addr_i[4];
            end

            else begin
                if (we_i || addr_i[8]) begin
                    slice_o[0] = 1;
                end
                else begin 
                    slice_o = {NUM_OF_SLICE{1'b1}};
                    send_spike_o = 1;
                end
            end
        end

    end

endmodule
