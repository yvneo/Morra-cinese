// Code your testbench here
// or browse Examples
`timescale 1ns / 1ps

module tb();
  integer tbf, outf; 
  
  reg [1:0] PRIMO;
  reg [1:0] SECONDO;
  reg INIZIA;
  reg clock;
  reg [1:0] MANCHE;
  reg [1:0] PARTITA;
    
  manche fun(.PRIMO(PRIMO), .SECONDO(SECONDO), .INIZIA(INIZIA), .clk(clock), .MANCHE(MANCHE), .PARTITA(PARTITA));
  
  always #10 clock = ~clock; 
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1);
    tbf = $fopen("testbench.script", "w");
    outf = $fopen("output_verilog.txt", "w");
    // $fdisplay(tbf, "read_blif FSMD.blif");
    
    clock = 1'b0; 
	INIZIA = 1'b0;
    
    #20
    
    INIZIA = 1'b1;
   	PRIMO <= 2'b00;
    SECONDO <= 2'b10;
	$fdisplay(outf, "Outputs: %b %b %b %b", MANCHE[1], MANCHE[0], PARTITA[1], PARTITA[0]);
    
    #20
    
    INIZIA = 1'b0;
    PRIMO <= 2 'b01;
    SECONDO <= 2 'b01; 
    #20
    $fdisplay(outf, "Outputs: %b %b %b %b", MANCHE[1], MANCHE[0], PARTITA[1], PARTITA[0]);
    
    PRIMO <= 2 'b11;
    SECONDO <= 2 'b10; 
    #20
    $fdisplay(outf, "Outputs: %b %b %b %b", MANCHE[1], MANCHE[0], PARTITA[1], PARTITA[0]);
    
    PRIMO <= 2 'b01;
    SECONDO <= 2 'b10; 
    #20
    $fdisplay(outf, "Outputs: %b %b %b %b", MANCHE[1], MANCHE[0], PARTITA[1], PARTITA[0]);
    
    PRIMO <= 2 'b11;
    SECONDO <= 2 'b01; 
    #20
    $fdisplay(outf, "Outputs: %b %b %b %b", MANCHE[1], MANCHE[0], PARTITA[1], PARTITA[0]);
    
    PRIMO <= 2 'b00;
    SECONDO <= 2 'b00; 
    #20
    $fdisplay(outf, "Outputs: %b %b %b %b", MANCHE[1], MANCHE[0], PARTITA[1], PARTITA[0]);
    
    PRIMO <= 2 'b01;
    SECONDO <= 2 'b01; 
    #20
    $fdisplay(outf, "Outputs: %b %b %b %b", MANCHE[1], MANCHE[0], PARTITA[1], PARTITA[0]);
    
    PRIMO <= 2 'b01;
    SECONDO <= 2 'b10; 
    #20
    $fdisplay(outf, "Outputs: %b %b %b %b", MANCHE[1], MANCHE[0], PARTITA[1], PARTITA[0]);
    
    PRIMO <= 2 'b10;
    SECONDO <= 2 'b01; 
    #20
    $fdisplay(outf, "Outputs: %b %b %b %b", MANCHE[1], MANCHE[0], PARTITA[1], PARTITA[0]);
    
    
    $display(tbf, "quit");
    $fclose(tbf);
    $fclose(outf);
    $finish;
  end  
     
endmodule