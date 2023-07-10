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
    wire                reset;
    wire                conect_count_to_srfs;
    //conectamos sr,fs al mux y o_mux nos da la salida 
    wire [NB_LEDS-1:0]  o_mux_to_leds;
    wire [NB_LEDS-1:0]  sr_to_mux;
    wire [NB_LEDS-1:0]  fs_to_mux;
    wire [NB_LEDS-1:0]  fs2led_to_mux;

    //RGB
    //wire [NB_LEDS-1:0]  ;
    reg  [1:0]            color_led;//00->red 01->green 10->blue
    reg  [1:0]            work_state;//00->sr , 01->fs , 10->sr2led

    //para guardar el estado del btn para que funcione por flanco
    reg                 btn_saver; 
    //for vio
    wire [NB_SW-1 :0]   sw_from_vio;
    wire [NB_SW-1 :0]   btn_from_vio;
    wire                reset_from_vio;
    wire                sel_mux;
    wire [NB_SW-1 :0]   sw_wire;
    wire [NB_SW-1 :0]   btn_wire;

    

    assign sw_wire = (sel_mux) ? sw_from_vio:
                                 i_sw;
    assign btn_wire = (sel_mux) ? btn_from_vio:
                                  i_btn;
    //Reset hardware o de vio                             
    assign reset = (sel_mux) ? ~reset_from_vio : 
                               ~i_reset;

    //Selecciono el modo de salida con btn[0]                           
    //assign o_mux_to_leds = (btn_wire[0]== 1'b1) ? fs_to_mux : sr_to_mux;
    


    count
    #(
        .NB_SW      (NB_SW-1 ),
        .NB_COUNTER (NB_COUNTER)
    )
    u_count
    (
        .o_valid(conect_count_to_srfs),
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
        .i_valid(conect_count_to_srfs),
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
        .i_valid(conect_count_to_srfs), 
        .i_reset(reset),
        .clock(clock)
    );
    
    shiftreg2led
    #(
        .NB_LEDS(NB_LEDS)
    )
    u_shiftreg2led
    (
        .o_led(fs2led_to_mux),
        .i_valid(conect_count_to_srfs), 
        .i_reverse(sw_wire[3]), 
        .i_reset(reset),
        .clock(clock)
                        
    );



    always @(posedge clock) begin
        if(reset)begin
            color_led  <= 2'b00;
            work_state <= 2'b00;
            btn_saver  <= btn_wire[0];
        end
        else begin
            //logica para selector de modo de trabajo
            //btn_saver  <= btn_wire[0];//pa mi esto va al final
            if(btn_wire[0]==1'b1 && btn_saver==1'b0)begin //TODO: HACER POR FLAAAANCO!!!!!!!!!
                work_state <= (work_state == 2'b00) ? 2'b01 :
                              (work_state == 2'b01) ? 2'b10 :
                                                      2'b00 ;
            end
            else begin 
                work_state <= work_state;
            end

            //Logica para el selector de color
            if(btn_wire[3:1]==3'b001) begin
                color_led <= 2'b00;
            end
            else if(btn_wire[3:1]==3'b010) begin
                color_led <= 2'b01;
            end
            else if(btn_wire[3:1]==3'b100) begin
                color_led <= 2'b10;
            end
            else begin
            color_led  <= color_led;
            //work_state <= work_state;
            end
            btn_saver  <= btn_wire[0];
        end
    end

    assign o_mux_to_leds = (work_state == 2'b00) ? fs_to_mux :
                           (work_state == 2'b01) ? sr_to_mux :
                                                fs2led_to_mux;
    
    //Seleccion de color                           
    assign o_led_r = (color_led == 2'b00) ? o_mux_to_leds : 4'b0000  ;
    assign o_led_g = (color_led == 2'b01) ? o_mux_to_leds : 4'b0000  ;
    assign o_led_b = (color_led == 2'b10) ? o_mux_to_leds : 4'b0000  ;
    assign o_led   =  btn_wire;//   = (btn_wire[3:1]==3b'001) ? o_mux_to_leds : 4b'0000  ;



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