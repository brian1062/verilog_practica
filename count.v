//Primer jerarquia
module count
#(  //Parametrizacion
    parameter NB_SW = 3 ,
    parameter NB_COUNTER =32
)
(
    output                  o_valid, //senial de habilitacion
    input [NB_SW -1 : 0]    i_sw,
    input                   i_reset,
    input                   clock
);

    //Localparam
    localparam R0 = (2**(NB_COUNTER-10))-1;
    localparam R1 = (2**(NB_COUNTER-11))-1;
    localparam R2 = (2**(NB_COUNTER-12))-1;
    localparam R3 = (2**(NB_COUNTER-13))-1;//Mas rapida pq tengo menos limit


    //Vars
    reg [NB_COUNTER -1 :0] counter;
    reg                     valid;
    wire [NB_COUNTER -1 :0] limit_counter;

    assign limit_counter = (i_sw[2:1]==2'b00)? R0 : 
                           (i_sw[2:1]==2'b01)? R1 :
                           (i_sw[2:1]==2'b10)? R2 : R3;


    always @(posedge clock) begin
        
        if(i_reset) begin
            counter <=  {NB_COUNTER{1'b0}};//h'0//32'd0;
            valid <= 1'b0;
        end
        else if (i_sw[0])begin

            if(counter >= limit_counter) begin
                counter <= {NB_COUNTER{1'b0}};
                valid <= 1'b1;
            end
            else begin 
                counter <= counter + {{NB_COUNTER-1{1'b0}},1'b1};
                valid <= 1'b0;
            end
        end
        //En estado (0) todo se detiene sin alterar el estado actual del contador y del SR/FS.
        //else if (~i_sw[0])begin
        //    valid <= 1'b0;
        //end
        else begin 
            counter <= counter;
            valid <= valid;
        end

    end

    assign o_valid = valid;



endmodule