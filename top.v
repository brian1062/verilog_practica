module top
#(
    parameter NB_SW = 4 ,
    parameter NB_COUNTER =32,
    parameter NB_LEDS = 4
)
(
    output [NB_LEDS-1:0] o_led,
    output [NB_LEDS-1:0] o_led_b,
    output [NB_LEDS-1:0] o_led_g,

    input [NB_SW-1:0] i_sw,
    input  i_reset,
    input clock
);
    //Vars
    wire conect_count_to_sr;
    wire [NB_LEDS -1 :0]conect_led_to_mux;

    count
        #(
            .NB_SW      (NB_SW-1 ),
            .NB_COUNTER (NB_COUNTER)
        )
        u_count
        (
            .o_valid(conect_count_to_sr),
            .i_sw (i_sw[2:0]),
            .i_reset(~i_reset),
            .clock(clock)

        );
    
    shiftreg
        #(
           .NB_LEDS(NB_LEDS)
        )

        u_shiftreg
        (
            .o_led(conect_led_to_mux),
            .i_valid(conect_count_to_sr),
            .i_reset(~i_reset),
            .clock(clock)
        );

    assign o_led = conect_led_to_mux;
    assign o_led_b= (i_sw[3]==1'b0) ? conect_led_to_mux: 4'b0000;
    assign o_led_g= (i_sw[3]==1'b0) ? 4'b0000          :  conect_led_to_mux;


endmodule