module flash
#(
    parameter NB_LEDS = 4

)
(
    output [NB_LEDS-1 :0]   o_led,
    input                   i_valid, //la de habilitacion que entra
    input                   i_reset,
    input                   clock
);

    reg [NB_LEDS-1 :0] leds_reg;

    integer ptr;

    always @(posedge clock) begin
        if(i_reset) begin
            leds_reg <= {NB_LEDS{1'b1}};//4'b1111;por consigna
        end
        else if (i_valid) begin
            leds_reg <= ~leds_reg;
        end
        else begin
            leds_reg <= leds_reg;
        end
    end

    assign o_led = leds_reg;

endmodule