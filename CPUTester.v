module LabN3;

reg [31:0] entryPoint;
reg clk, INT;
wire RegDst, RegWrite, ALUSrc, MemRead, MemWrite, Mem2Reg, branch, jump;
wire[2:0] op;
wire[1:0] ALUop;
wire[5:0] opCode, fnCode;
wire [31:0] ins, PCp4, wd, rd1, rd2, imm, z, memOut, wb, PCin;
wire[25:0] jTarget;
wire zero;

yIF myIF(ins, PCin, PCp4, clk);
yID myID(rd1, rd2, imm, jTarget, ins, wd, RegDst, RegWrite, clk);
yEX myEx(z, zero, rd1, rd2, imm, op, ALUSrc);
yDM myDM(memOut, z, rd2, clk, MemRead, MemWrite);
yWB myWB(wb, z, memOut, Mem2Reg);
assign wd = wb;
yPC myPC(PCin, PCp4,INT,entryPoint,imm,jTarget,zero,branch,jump);
assign opCode = ins[31:26];
yC1 myC1(rtype, lw, sw, jump, branch, opCode);
yC2 myC2(RegDst, ALUSrc, RegWrite, Mem2Reg, MemRead, MemWrite, rtype, lw, sw, branch);
assign fnCode = ins[5:0];
yC3 myC3(ALUop, rtype, branch);
yC4 myC4(op, ALUop, fnCode);

initial
begin
    entryPoint=128; INT = 1; #1; // entry point

    //run program
    repeat (43) begin
        clk = 1; #1; INT = 0; // fetch an ins

        // set control signals
        //op=3'b010;

        clk = 0; #1; // execute the ins

        //view results
        $display("%h: rd1=%2d rd2=%2d z=%3d zero=%b wb=%2d", ins, rd1, rd2, z, zero, wb);
    end
    $finish;
end
endmodule