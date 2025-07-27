module yMux1(z, a, b, c);
output z;
input a,b,c;
wire notC, upper, lower;

not my_not(notC, c);
and upperAnd(upper, a, notC);
and lowerAnd(lower, c, b);
or my_or(z, upper, lower);

endmodule

module yMux(z, a, b, c);
parameter SIZE = 2;
output [SIZE-1:0] z;
input [SIZE-1:0] a,b;
input c;

yMux1 mine[SIZE-1:0](z, a, b, c);

endmodule

module yMux4to1(z, a0, a1, a2, a3, c);
parameter SIZE = 2;
output [SIZE-1:0] z;
input [SIZE-1:0] a0, a1, a2, a3;
input [1:0] c;
wire [SIZE-1:0] zLo, zHi;

yMux #(SIZE) lo(zLo, a0, a1, c[0]);
yMux #(SIZE) hi(zHi, a2, a3, c[0]);
yMux #(SIZE) final(z, zLo, zHi, c[1]);

endmodule

module yAdder1(z, cout, a, b, cin);

output z, cout;
input a, b, cin;

xor left_xor(tmp, a, b);
xor right_xor(z, cin, tmp);
and left_and(outL, a, b);
and right_and(outR, tmp, cin);
or my_or(cout, outR, outL);

endmodule

module yAdder(z, cout, a, b, cin);
output [31:0] z;
output cout;
input [31:0] a, b;
input cin;
wire[31:0] in, out;

yAdder1 mine[31:0](z, out, a, b, in);

assign in[0] = cin;
assign in[1] = out[0];
assign in[2] = out[1];
assign in[3] = out[2];
assign in[4] = out[3];
assign in[5] = out[4];
assign in[6] = out[5];
assign in[7] = out[6];
assign in[8] = out[7];
assign in[9] = out[8];
assign in[10] = out[9];
assign in[11] = out[10];
assign in[12] = out[11];
assign in[13] = out[12];
assign in[14] = out[13];
assign in[15] = out[14];
assign in[16] = out[15];
assign in[17] = out[16];
assign in[18] = out[17];
assign in[19] = out[18];
assign in[20] = out[19];
assign in[21] = out[20];
assign in[22] = out[21];
assign in[23] = out[22];
assign in[24] = out[23];
assign in[25] = out[24];
assign in[26] = out[25];
assign in[27] = out[26];
assign in[28] = out[27];
assign in[29] = out[28];
assign in[30] = out[29];
assign in[31] = out[30];

assign cout = out[31];
endmodule

module yArith(z, cout, a, b, ctrl);
// add if ctrl=0, subtract if ctrl=1
output [31:0] z;
output cout;
input [31:0] a, b;
input ctrl;
wire[31:0] notB, tmp;
wire cin;

// instantiate the components and connect them
not my_not[31:0](notB, b);
assign tmp = ctrl ? notB : b;
assign cin = ctrl;
yAdder my_adder(z, cout, a, tmp, cin);

endmodule

module yAlu(z, ex, a, b, op);
input [31:0] a, b;
input [2:0] op;
output [31:0] z;
output ex;
wire [31:0] slt, sub;
assign slt[31:1] = 0; // upper bits are always 0

xor(condition, a[31], b[31]);
assign sub = a - b;
assign slt[0] = condition ? a[31] : sub[31];

wire [31:0] arith_result;
wire dropcarry;
yArith my_arith(arith_result, dropcarry, a, b, op[2]);
assign z = op[1] ? (op[0] ? slt : arith_result) : (op[0] ? (a|b) : (a&b));

wire[15:0] z16;
wire[7:0] z8;
wire[3:0] z4;
wire[1:0] z2;
wire z1;

or or16[15:0](z16, z[15:0], z[31:16]);
or or8[7:0](z8, z16[7:0], z16[15:8]);
or or4[3:0](z4, z8[3:0], z8[7:4]);
or or2[1:0](z2, z4[1:0], z4[3:2]);
or or1(z1, z2[1], z2[0]);

assign ex = ~z1;

endmodule

module yIF(ins, PCin, PCp4, clk);

input [31:0] PCin;
input clk;
output [31:0] PCp4, ins;

wire [31:0] tmp;
wire ex;
register #(32) PCreg(tmp, PCin, clk, 1'b1);

yAlu PCalu(.z(PCp4), .ex(), .a(tmp), .b(4), .op(3'b010));

mem PCmem(ins, tmp, 32'b0, clk, 1'b1, 1'b0);

endmodule

module yID(rd1, rd2, imm, jTarget, ins, wd, RegDst, RegWrite, clk);

output[31:0] rd1, rd2, imm;
output[25:0] jTarget;
input [31:0] ins, wd;
input RegDst, RegWrite, clk;

wire [15:0] zeros = 16'b0;
wire [15:0] ones = 16'b1111111111111111;
wire [4:0] rn1, rn2, wn;

assign rn1 = ins[25:21];
assign rn2 = ins[20:16];

assign imm[15:0] = ins[15:0];
assign jTarget = ins[25:0];
yMux #(16) se(imm[31:16], zeros, ones, ins[15]);

yMux #(5) PCMux(wn, rn2, ins[15:11], RegDst);

rf PCRF(rd1, rd2, rn1, rn2, wn, wd, clk, RegWrite);
endmodule

module yEX(z, zero, rd1, rd2, imm, op, ALUSrc);

output [31:0] z;
output zero;
input [31:0] rd1, rd2, imm;
input [2:0] op;
input ALUSrc;

wire[31:0] tmp;

yMux #(32) PCMux(tmp, rd2, imm, ALUSrc);

yAlu PCAlu(z, zero, rd1, tmp, op);
endmodule

module yDM(memOut, exeOut, rd2, clk, MemRead, MemWrite);

output [31:0] memOut;
input [31:0] exeOut, rd2;
input clk, MemRead, MemWrite;

mem PCmem(memOut, exeOut, rd2, clk, MemRead, MemWrite);

endmodule

module yWB(wb, exeOut, memOut, Mem2Reg);

output [31:0] wb;
input [31:0] exeOut, memOut;
input Mem2Reg;

yMux #(32) PCMux(wb, exeOut, memOut, Mem2Reg);

endmodule

module yPC(PCin, PCp4,INT,entryPoint,imm,jTarget,zero,branch,jump);

output [31:0] PCin;
input [31:0] PCp4, entryPoint, imm;
input [25:0] jTarget;
input INT, zero, branch, jump;

wire [31:0] immX4, bTarget, choiceA, choiceB, jumpTarget, choiceC;
wire doBranch, zf;
assign immX4[31:2] = imm[29:0];
assign immX4[1:0] = 2'b00;

assign jumpTarget = {PCp4[31:28], jTarget, 2'b00};

yAlu myALU(bTarget, zf, PCp4, immX4, 3'b010);
and (doBranch, branch, zero);
yMux #(32) mux1(choiceA, PCp4, bTarget, doBranch);
yMux #(32) mux2(choiceB, choiceA, jumpTarget, jump);
yMux #(32) mux3(choiceC, choiceB, entryPoint, INT);

assign PCin = choiceC;
endmodule

module yC1(rtype, lw, sw, jump, branch, opCode);

output rtype, lw, sw, jump, branch;
input [5:0] opCode;

wire not5, not4, not3, not2, not1, not0;
not (not5, opCode[5]);
not (not4, opCode[4]);
not (not3, opCode[3]);
not (not2, opCode[2]);
not (not1, opCode[1]);
not (not0, opCode[0]);
and (lw, opCode[5], not4, not3, not2, opCode[1], opCode[0]);

and (sw, opCode[5], not4, opCode[3], not2, opCode[1], opCode[0]);
and (branch, not5, not4, not3, opCode[2], not1, not0);
and (jump, not5, not4, not3, not2, opCode[1], not0);
and(rtype, not5, not4, not3, not2, not1, not0);
endmodule

module yC2(RegDst, ALUSrc, RegWrite, Mem2Reg, MemRead, MemWrite, rtype, lw, sw, branch);

output RegDst, ALUSrc, RegWrite, Mem2Reg, MemRead, MemWrite;
input rtype, lw, sw, branch;

assign RegDst = rtype;
nor (ALUSrc, rtype, branch);
nor (RegWrite, sw, branch);
assign MemRead = lw;
assign Mem2Reg = lw;
assign MemWrite = sw;

endmodule

module yC3(ALUop, rtype, branch);
output [1:0] ALUop;
input rtype, branch;

assign ALUop[0] = branch;
assign ALUop[1] = rtype;

endmodule

module yC4(op, ALUop, fnCode);
output [2:0] op;
input [5:0] fnCode;
input [1:0] ALUop;

wire t1, t2;
or (t1, fnCode[0], fnCode[3]);
and (t2, fnCode[1], ALUop[1]);
and (op[0], ALUop[1], t1);
nand (op[1], ALUop[1], fnCode[2]);
or (op[2], t2, ALUop[0]);

endmodule