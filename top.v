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
    output [NB_LEDS-1:0] o_led,

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

    //for vio
    wire [NB_SW-1 :0]   sw_from_vio;
    wire [NB_SW-1 :0]   btn_from_vio;
    wire                reset_from_vio;
    wire                sel_mux;
    wire [NB_SW-1 :0]   sw_wire;
    wire [NB_SW-1 :0]   btn_wire;

    wire                reset;

    assign sw_wire = (sel_mux) ? sw_from_vio:
                                 i_sw;
    assign btn_wire = (sel_mux) ? btn_from_vio:
                                  i_btn;
    //Reset hardware o de vio
    assign reset = (sel_mux) ? ~reset_from_vio : 
                               ~i_reset;

    count
        #(
            .NB_SW      (NB_SW-1 ),
            .NB_COUNTER (NB_COUNTER)
        )
        u_count
        (
            .o_valid(conect_count_to_sr),
            .i_sw (sw_wire[2:0]),
            .i_reset(reset),
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
            .i_reverse(sw_wire[3]),
            .i_reset(reset),
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
            .i_reset(reset),
            .clock(clock)
        );
// ver bien
    always @(posedge clock) begin
        if(reset) begin //inicializo var de estado
            working_mode <= 1'b0;
            active_color_r <= 1'b0;
            active_color_b <= 1'b0;
            active_color_g <= 1'b0;
        end
        else if (btn_wire[0]) begin //pulso el boton cambio modo de trabajo
            working_mode <= (working_mode==1'b0) ? 1'b1 : 1'b0;
        end

        if(btn_wire[1]==1'b1)begin //red
            active_color_r <= 1'b1;
            active_color_b <= 1'b0;
            active_color_g <= 1'b0;
        end
        else if(btn_wire[2]==1'b1)begin //green
            active_color_r <= 1'b0;
            active_color_b <= 1'b0;
            active_color_g <= 1'b1;
        end
        else if(btn_wire[3]==1'b1)begin // blue
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

    //assign o_led[0]= working_mode;
    assign o_led[NB_LEDS-1 : 0]= {active_color_b,
                                 active_color_g,
                                 active_color_r,
                                 working_mode
                                 };
    ila
    u_ila
   (.clk_0(clock),
    .probe0_0(o_led_r),
    .probe1_0(o_led_g),
    .probe2_0(o_led_b),
    .probe3_0(o_led)
    );
    
    vio
    u_vio
   (.clk_0(clock),
    .probe_in0_0(o_led_r),
    .probe_in1_0(o_led_g),
    .probe_in2_0(o_led_b),
    .probe_in3_0(o_led),
    .probe_out0_0(sel_mux),        //selector:hardware o forma remota
    .probe_out1_0(reset_from_vio), //Reset sistema
    .probe_out2_0(sw_from_vio),    //Control sw
    .probe_out3_0(btn_from_vio)    //Control btn
    );

endmodule