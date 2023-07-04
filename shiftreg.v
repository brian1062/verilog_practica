//Segunda jerarquia
module shiftreg
#(
    parameter NB_LEDS = 4

)
(
    output [NB_LEDS-1 :0]   o_led,
    input                   i_valid, //la de habilitacion que entra
    input                   i_reset,
    input                   clock
);


    //VARS
    reg [NB_LEDS-1 :0] shiftregisters;


    //OPT1 FOR
    integer ptr;


    always @(posedge clock) begin
        if(i_reset)begin 
            shiftregisters <= {{NB_LEDS{1'b0}},1'b1};//4'b0001;
        end 
        else if (i_valid)begin
            //---------------------------------------------
            //OP1 FOR
            for(ptr=0;ptr<NB_LEDS-1;ptr=ptr+1) begin
                shiftregisters[ptr +1] <= shiftregisters[ptr];
            end
            shiftregisters[0] <= shiftregisters[NB_LEDS-1];
            //---------------------------------------------

            //OP2 
            //shiftregisters <= shiftregisters << 1;
            //shiftregisters[0] <= shiftregisters[NB_LEDS-1]

            //OP3
            //shiftregisters <= {shiftregisters[NB_LEDS-2:0],shiftregisters[NB_LEDS-1]}
        end
        else begin 
            shiftregisters <= shiftregisters;
        end       
    end


    assign o_led = shiftregisters;

endmodule