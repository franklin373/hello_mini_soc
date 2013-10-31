module sram_adaptor_en(
    iRst,
    iClock,
    oAdaptor_en,
    );
    input iRst;
    input iClock;
    output oAdaptor_en;

    reg[7:0] count;
    reg oAdaptor_en;
    wire[7:0] count_next;
    assign count_next=count+8'b1;
    always @(posedge iClock or posedge iRst) begin  
        if(iRst)
            count<=0;
        else
            count<=count_next;
    end
    always @(posedge iClock or posedge iRst) begin
        if(iRst)
            oAdaptor_en<=1'b0;
//        else if(count_next==8'd41)
//            oAdaptor_en<=1'b0;
        else
            oAdaptor_en<=1'b1;
    end
endmodule