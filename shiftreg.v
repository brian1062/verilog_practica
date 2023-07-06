//Segunda jerarquia
module shiftreg
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


    //VARS
    reg [NB_LEDS-1 :0] shiftregisters;

    reg direction;

    //OPT1 FOR
    integer ptr;


    always @(posedge clock) begin
        if(i_reset)begin 
            shiftregisters <= {{NB_LEDS-1{1'b0}},{1'b1}};//4'b0001;
            direction <= 1'b0;
        end 
        else if (i_valid)begin
            if(i_reverse)begin
                direction <= ~direction;
            end

            if(direction == 1'b0)begin
                shiftregisters <= {shiftregisters[NB_LEDS-2:0], shiftregisters[NB_LEDS-1]};
            end
            else begin
                shiftregisters <= {shiftregisters[0], shiftregisters[NB_LEDS-1:1]};
            end

        end
        else begin 
            shiftregisters <= shiftregisters;
            direction <= direction;
        end       
    end


    assign o_led = shiftregisters;

endmodule