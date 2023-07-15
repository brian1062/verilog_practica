//Segunda jerarquia
module shiftreg2led
#(
    parameter NB_LEDS = 4

)
(
    output [NB_LEDS-1 :0]   o_led,
    input                   i_valid, //la de habilitacion que entra
    input                   i_reverse, //cambio de sentido
    input                   i_reset,
    input                   clock
                       
);
    //Localparam
    localparam o_1 = 4'b1001;
    localparam o_2 = 4'b0110;
    localparam o_3 = 4'b0000;
    //localparam R3 = (2**(NB_COUNTER-13))-1;

    
    //VARS
    reg [NB_LEDS-1 :0] shiftregisters;

    //reg direction;

    //OPT1 FOR
    integer ptr;


    always @(posedge clock or posedge i_reset) begin
        if(i_reset)begin 
            shiftregisters <= o_3;//4'b0000;
            //direction <= 1'b0;
        end 
        else if (i_valid)begin
            //if(i_reverse)begin
            //    direction <= ~direction;//creo que esto esta modelado como un boton
            //end

            //if(direction == 1'b0)begin
            if(~i_reverse)begin    
                shiftregisters <= (shiftregisters== o_3) ?  o_1 :
                                  (shiftregisters== o_1) ?  o_2 :
                                                            o_3 ;
            end
            else begin
                shiftregisters <= (shiftregisters== o_3) ?  o_2 :
                                  (shiftregisters== o_2) ?  o_1 :
                                                            o_3 ;
            end

        end
        else begin 
            shiftregisters <= shiftregisters;
            //direction <= direction;
        end       
    end


    assign o_led = shiftregisters;

endmodule