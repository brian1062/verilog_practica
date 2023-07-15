// TB
// tp4
`define NB_LEDS 4
`define NB_COUNTER 14
`define NB_SW 4

`timescale 1ns/100ps

module tb_tp4();

   parameter NB_LEDS   = `NB_LEDS   ;
   //parameter NB_SEL   = `NB_SEL   ;
   parameter NB_COUNTER = `NB_COUNTER ;
   parameter NB_SW    = `NB_SW    ;

   wire [NB_LEDS - 1 : 0] o_led    ;
   wire [NB_LEDS - 1 : 0] o_led_r  ;
   wire [NB_LEDS - 1 : 0] o_led_b  ;
   wire [NB_LEDS - 1 : 0] o_led_g  ;
   reg  [NB_SW   - 1 : 0] i_sw    ;
   reg  [NB_SW - 1 : 0] i_btn ;
   reg                   i_reset  ;
   reg                   clock    ;

   initial begin
      i_sw[0]             = 1'b0       ;
      clock               = 1'b0       ;
      i_reset             = 1'b0       ;
      i_sw[2:1]           = 2'b00      ;
      i_sw[3]             = 1'b0       ;//este cambia sentido del sr
      i_btn[0]            = 1'b0       ;//este cambia de modo de trabajo
      i_btn[3:1]          = 3'b000     ;
      #100 i_reset        = 1'b1       ;
      #100 i_sw[0]        = 1'b1       ;
      #100 i_btn[0]   = 1'b1           ;
      #100 i_sw[3]    = 1'b1           ;
      #200 i_btn[0]   = 1'b0           ;
      #1000 i_reset        = 1'b0       ;
      #1010 i_reset        = 1'b1       ;
      #1000000 i_btn[0]   = 1'b1       ;
      #1000010 i_btn[0]   = 1'b0       ;
      #1000010 i_btn[2]   = 1'b1       ;
      #1000020 i_btn[2]   = 1'b0       ;
      #1000025 i_btn[0]   = 1'b0       ;
      #1000030 i_btn[0]   = 1'b1       ;
      #1000035 i_btn[0]   = 1'b0       ;


      #2000000 $finish                 ;
   end

   always #5 clock = ~clock;

top
  #(
    .NB_LEDS   (NB_LEDS)  ,
    .NB_COUNTER (NB_COUNTER),
    .NB_SW    (NB_SW)
    )
  u_top
    (
     
     .o_led_r   (o_led_r)  ,
     .o_led_b   (o_led_b)  ,
     .o_led_g   (o_led_g)  ,
     .o_led     (o_led)    ,
     .i_btn     (i_btn),
     .i_sw      (i_sw)     ,
     .i_reset   (i_reset)  ,
     .clock     (clock)
     );

endmodule // tb_tp4