module top
#(
    parameter NB_SW = 4 ,
    parameter NB_COUNTER =32,
    parameter NB_LEDS = 4
)
(
    output [NB_LEDS-1:0] o_led_r,
    output [NB_LEDS-1:0] o_led_b,
    output [NB_LEDS-1:0] o_led_g,

    input [NB_SW-1:0] i_btn,
    input [NB_SW-1:0]  i_sw,
    input i_reset,
    input clock
);

    //localparam R0;
    //Vars
    wire conect_count_to_sr;
    //wire [NB_LEDS -1 :0]conect_led_to_mux;

    reg working_mode;//0->SR; 1->FS
    //no quiero hacer 3 reg pero son medidas desesperadas
    reg active_color_r;//TODO : CAMBIAR ESTO, FUNCIONA PERO QUIERO USAR 1 REGISTRO
    reg active_color_g;
    reg active_color_b;

    wire [NB_LEDS-1 :0] fs_to_mux;
    wire [NB_LEDS-1 :0] sr_to_mux;
    wire [NB_LEDS-1 :0] connect_mux_to_leds;


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
            .o_led(sr_to_mux), 
            .i_valid(conect_count_to_sr),
            .i_reverse(i_sw[3]),
            .i_reset(~i_reset),
            .clock(clock)
        );
    flash
        #(
            .NB_LEDS(NB_LEDS)
        )

        u_flash
        (
            .o_led(fs_to_mux),   
            .i_valid(conect_count_to_sr), 
            .i_reset(~i_reset),
            .clock(clock)
        );
// ver bien
    always @(posedge clock) begin
        if(i_reset) begin //inicializo var de estado
            working_mode <= 1'b0;
            active_color_r <= 1'b0;
            active_color_b <= 1'b0;
            active_color_g <= 1'b0;
        end
        else if (i_btn[0]) begin //pulso el boton cambio modo de trabajo
            working_mode <= (working_mode==1'b0) ? 1'b1 : 1'b0;
        end

        if(i_btn[1]==1'b1)begin //red
            active_color_r <= 1'b1;
            active_color_b <= 1'b0;
            active_color_g <= 1'b0;
        end
        else if(i_btn[2]==1'b1)begin //green
            active_color_r <= 1'b0;
            active_color_b <= 1'b0;
            active_color_g <= 1'b1;
        end
        else if(i_btn[3]==1'b1)begin // blue
            active_color_r <= 1'b0;
            active_color_b <= 1'b1;
            active_color_g <= 1'b0;
        end
        else begin
            working_mode <= working_mode;
            //active_color <= active_color;
            active_color_r <= active_color_r;
            active_color_b <= active_color_b;
            active_color_g <= active_color_g;
        end
    end


    assign o_led_r = (active_color_r==1'b1) ?
                                    ((working_mode==1'b0) ? sr_to_mux : fs_to_mux):
                                    4'b0000;
    assign o_led_g= (active_color_g==1'b1) ?
                                    ((working_mode==1'b0) ? sr_to_mux : fs_to_mux):
                                    4'b0000;
    assign o_led_b= (active_color_b==1'b1) ?
                                    ((working_mode==1'b0) ? sr_to_mux : fs_to_mux):
                                    4'b0000;
    /*assign o_led_r = (active_color == 2'b00 && working_mode == 1'b0) ? sr_to_mux : 4'b0000;
    assign o_led_g = (active_color == 2'b01 && working_mode == 1'b0) ? sr_to_mux : 4'b0000;
    assign o_led_b = (active_color == 2'b10 && working_mode == 1'b0) ? sr_to_mux : 4'b0000;
    */

endmodule