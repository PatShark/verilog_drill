module CORDIC(i_clk,en,din,dout,cos,sin);
    input i_clk,en;
    input [31:0] din;
    output wire [31:0] dout,cos,sin;

    wire clk;
    wire [1:0] quadrant0,quadrant1,quadrant2,quadrant3,quadrant4,quadrant5,quadrant6,quadrant7,quadrant8,quadrant9,quadrant10;
    wire [31:0] pip0,pip1,pip2,pip3,pip4,pip5,pip6,pip7,pip8,pip9,pip10;
    wire [31:0] cos1,cos2,cos3,cos4,cos5,cos6,cos7,cos8,cos9,cos10;
    wire [31:0] sin1,sin2,sin3,sin4,sin5,sin6,sin7,sin8,sin9,sin10;
    wire [31:0] angle1,angle2,angle3,angle4,angle5,angle6,angle7,angle8,angle9,angle10;

    parameter a0=32'h002d0000;
    parameter a1=32'h001a90a7;
    parameter a2=32'h000e0947;
    parameter a3=32'h00072001;
    parameter a4=32'h0003938b;
    parameter a5=32'h0001ca38;
    parameter a6=32'h0000e52a;
    parameter a7=32'h00007297;
    parameter a8=32'h0000394c;
    parameter a9=32'h00001ca6;

    parameter c0=4'd0;
    parameter c1=4'd1;
    parameter c2=4'd2;
    parameter c3=4'd3;
    parameter c4=4'd4;
    parameter c5=4'd5;
    parameter c6=4'd6;
    parameter c7=4'd7;
    parameter c8=4'd8;
    parameter c9=4'd9;

    parameter cos0=32'h00009b74;
    parameter sin0=32'h00000000;
    parameter angle0=32'h00000000;

    assign clk = i_clk & en;

    prepro prepro_inst(clk,din,pip0,quadrant0);

    pipro pipro0(clk,pip0,quadrant0,cos0,sin0,angle0,a0,c0,pip1,quadrant1,cos1,sin1,angle1);
    pipro pipro1(clk,pip1,quadrant1,cos1,sin1,angle1,a1,c1,pip2,quadrant2,cos2,sin2,angle2);
    pipro pipro2(clk,pip2,quadrant2,cos2,sin2,angle2,a2,c2,pip3,quadrant3,cos3,sin3,angle3);
    pipro pipro3(clk,pip3,quadrant3,cos3,sin3,angle3,a3,c3,pip4,quadrant4,cos4,sin4,angle4);
    pipro pipro4(clk,pip4,quadrant4,cos4,sin4,angle4,a4,c4,pip5,quadrant5,cos5,sin5,angle5);
    pipro pipro5(clk,pip5,quadrant5,cos5,sin5,angle5,a5,c5,pip6,quadrant6,cos6,sin6,angle6);
    pipro pipro6(clk,pip6,quadrant6,cos6,sin6,angle6,a6,c6,pip7,quadrant7,cos7,sin7,angle7);
    pipro pipro7(clk,pip7,quadrant7,cos7,sin7,angle7,a7,c7,pip8,quadrant8,cos8,sin8,angle8);
    pipro pipro8(clk,pip8,quadrant8,cos8,sin8,angle8,a8,c8,pip9,quadrant9,cos9,sin9,angle9);
    pipro pipro9(clk,pip9,quadrant9,cos9,sin9,angle9,a9,c9,pip10,quadrant10,cos10,sin10,angle10);

    aftpro aftpro_inst(clk,pip10,quadrant10,cos10,sin10,angle10,dout,cos,sin);
endmodule

module prepro(clk,din,pip,quadrant);
    input clk;
    input signed [31:0] din;
    output reg signed [31:0] pip;
    output reg [1:0] quadrant;

    always@(posedge clk)
    begin
        if(din>=32'h010e0000)
        begin
            pip<=din-32'h010e0000;
            quadrant<=2'b11;
        end
        else if(din>=32'h00b40000)
        begin
            pip<=din-32'h00b40000;
            quadrant<=2'b10;
        end
        else if(din>=32'h005a0000)
        begin
            pip<=din-32'h005a0000;
            quadrant<=2'b01;
        end
        else
        begin
            pip<=din;
            quadrant<=2'b00;
        end
    end
endmodule

module pipro(clk,pipin,quadrantin,cosin,sinin,anglein,a,c,pipout,quadrantout,cosout,sinout,angleout);
    input clk;
    input [1:0] quadrantin;
    input [3:0] c;
    input signed [31:0] pipin,cosin,sinin,anglein,a;

    output reg signed [31:0] pipout,cosout,sinout,angleout;
    output reg [1:0] quadrantout;

    always@(posedge clk)
    begin
        if(pipin>=anglein)
        begin
            cosout<=cosin-(sinin>>>c);
            sinout<=sinin+(cosin>>>c);
            angleout<=anglein+a;
        end
        else
        begin
            cosout<=cosin+(sinin>>>c);
            sinout<=sinin-(cosin>>>c);
            angleout<=anglein-a;
        end

        pipout<=pipin;
        quadrantout<=quadrantin;
    end
endmodule

module aftpro(clk,pip,quadrant,cosin,sinin,anglein,dout,cos,sin);
    input clk;
    input signed [31:0] pip,cosin,sinin,anglein;
    input [1:0] quadrant;

    output reg signed [31:0] dout,cos,sin;

    always@(posedge clk)
    begin
        case(quadrant)
        2'b00:
        begin
            dout<=pip;
            cos<=cosin;
            sin<=sinin;
        end
        2'b01:
        begin
            dout<=pip+32'h005a0000;
            cos<=(-sinin);
            sin<=cosin;
        end
        2'b10:
        begin
            dout<=pip+32'h00b40000;
            cos<=(-cosin);
            sin<=(-sinin);
        end
        2'b11:
        begin
            dout<=pip+32'h010e0000;
            cos<=sinin;
            sin<=(-cosin);
        end
        default:
        begin
            dout<=32'h00000000;
            cos<=32'h00000000;
            sin<=32'h00000000;
        end
        endcase
    end
endmodule
