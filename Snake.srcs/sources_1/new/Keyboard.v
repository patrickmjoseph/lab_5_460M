/***********************************************
 * Patrick Malikkal Joseph, Brady Alan Romero  *
 * EE 460M: Lab 5                              *
 * Keyboard Interface                          *
 ***********************************************/
   
 module sevenseg(clk, KBclk, KBdata, SevSegDisp);
    input clk, KBclk, KBdata;
    output reg[6:0] SevSegDisp;
    reg [7:0]keyval;
    reg [1:0]SevSegCtl;
    reg FltrClk;
    wire clk1K, FltrData;
    
    clkDivider SevSeg(clk, clk1K, 17'd100000); //clkdivider for clk to be 100khz for sevsegdisp
    filter filterVal(clk, KBclk, KBdata, FltrClk, FltrData);
    read_val readVal(FltrClk, FltrData, keyval);
    
    initial begin
        SevSegDisp = 0;
        keyval = 0;
        SevSegCtl = 3; //negative logic
        FltrClk = 1;
    end
    
    always @(posedge clk1K) begin
        if(~FltrClk) begin
            SevSegCtl = 2;
        end
        if(SevSegCtl==2) begin
            case(keyval[3:0])
                0: begin
                    SevSegDisp[6:0] <= 7'b1000000;
                end
                1: begin
                    SevSegDisp[6:0] <= 7'b1111001;
                end
                2: begin
                    SevSegDisp[6:0] <= 7'b0100100;
                end
                3: begin
                    SevSegDisp[6:0] <= 7'b0110000;            
                end
                4: begin
                    SevSegDisp[6:0] <= 7'b0011001;           
                end
                5: begin
                    SevSegDisp[6:0] <= 7'b0010010;
                end
                6: begin
                    SevSegDisp[6:0] <= 7'b0000010;
                end
                7: begin
                    SevSegDisp[6:0] <= 7'b1111000;
                end
                8: begin
                    SevSegDisp[6:0] <= 7'b0000000;
                end
                9: begin
                    SevSegDisp[6:0] <= 7'b0010000;
                end
                10: begin
                    SevSegDisp[6:0] <= 7'b0001000;
                end
                11: begin
                    SevSegDisp[6:0] <= 7'b0000011;
                end
                12: begin
                    SevSegDisp[6:0] <= 7'b1000110;
                end
                13: begin
                    SevSegDisp[6:0] <= 7'b0100001;
                end
                14: begin
                    SevSegDisp[6:0] <= 7'b0000110;
                end
                15: begin
                    SevSegDisp[6:0] <= 7'b0001110;
                end
                default: begin end
           endcase
       end
       if(SevSegCtl==1) begin
           case(keyval[7:4])
               0: begin
                   SevSegDisp[6:0] <= 7'b1000000;
               end
               1: begin
                   SevSegDisp[6:0] <= 7'b1111001;
               end
               2: begin
                   SevSegDisp[6:0] <= 7'b0100100;
               end
               3: begin
                   SevSegDisp[6:0] <= 7'b0110000;            
               end
               4: begin
                   SevSegDisp[6:0] <= 7'b0011001;           
               end
               5: begin
                   SevSegDisp[6:0] <= 7'b0010010;
               end
               6: begin
                   SevSegDisp[6:0] <= 7'b0000010;
               end
               7: begin
                   SevSegDisp[6:0] <= 7'b1111000;
               end
               8: begin
                   SevSegDisp[6:0] <= 7'b0000000;
               end
               9: begin
                   SevSegDisp[6:0] <= 7'b0010000;
               end
               10: begin
                   SevSegDisp[6:0] <= 7'b0001000;
               end
               11: begin
                   SevSegDisp[6:0] <= 7'b0000011;
               end
               12: begin
                   SevSegDisp[6:0] <= 7'b1000110;
               end
               13: begin
                   SevSegDisp[6:0] <= 7'b0100001;
               end
               14: begin
                   SevSegDisp[6:0] <= 7'b0000110;
               end
               15: begin
                   SevSegDisp[6:0] <= 7'b0001110;
               end
               default: begin end
          endcase
      end
      SevSegCtl <= {SevSegCtl[0], SevSegCtl[1]};
    end
    
 endmodule
 
 module read_val(KBclk, KBdata, keyval);
    input KBclk, KBdata; //keyboard clock 
    output [7:0]keyval; //modified output value for key press
    reg [7:0]keyval;
    reg [10:0]keyval_R; //raw value read from keyboard
    reg [4:0]counter;   //counts number of bits in shift reg
    
    initial
        begin
            keyval_R <= 11'b00000000000;
            counter <= 5'b00000;
        end
        
    always @(negedge KBclk) begin
        if(counter != 11) begin    
            keyval_R <= KBdata & keyval_R[10:1];
            counter <= counter + 1;
        end
        else begin
            counter <= 0;
            keyval <= keyval_R[8:1];
        end
    end    
    
 endmodule
 
 module filter(clk25M, KBclk, KBdata, FltrClk, FltrData);
    input clk25M, KBclk, KBdata;
    output reg FltrClk, FltrData;
    reg [7:0]ClkBuffer, DataBuffer;
    
    always @(posedge clk25M) begin
        ClkBuffer[7] = KBclk;
        DataBuffer[7] = KBdata;
        ClkBuffer[6:0] <= ClkBuffer[7:1];
        DataBuffer[6:0] <= DataBuffer[7:1];
        if(ClkBuffer == 8'hFF) begin
            FltrClk <= 1;
        end
        else if(ClkBuffer == 8'h00) begin
            FltrClk <= 0;
        end
        else begin end        
        if(DataBuffer == 8'hFF) begin
            FltrData <= 1;
        end
        else if(DataBuffer == 8'h00) begin
            FltrData <= 0;
        end
        else begin end 
    end     
    
 endmodule

module clkDivider(clk100Mhz, slowClk, divVal);
  input clk100Mhz; //fast clock
  input [16:0]divVal; //value to slow clk by
  output reg slowClk; //slow clock

  reg[27:0] counter;

  initial begin
    counter = 0;
    slowClk = 0;
  end

  always @ (posedge clk100Mhz)
  begin
    if(counter == divVal) begin
      counter <= 1;
      slowClk <= ~slowClk;
    end
    else begin
      counter <= counter + 1;
    end
  end
endmodule
 