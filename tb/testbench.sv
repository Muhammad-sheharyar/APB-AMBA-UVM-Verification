//-------------------------------------------------------------------------
//				www.verificationguide.com   testbench.sv
//-------------------------------------------------------------------------
//---------------------------------------------------------------
//including interfcae and testcase files

`include "uvm_macros.svh"
import uvm_pkg::*;
import apb_tb_uvm_pkg::*;

// `include "mem_interface.sv"
// `include "mem_base_test.sv"
// `include "mem_wr_rd_test.sv"
//---------------------------------------------------------------

module tbench_top;

  //---------------------------------------
  //clock and reset signal declaration
  //---------------------------------------
  logic PCLK;
  logic PRESETn;
  
  //---------------------------------------
  //clock generation
  //---------------------------------------
  
  always #5 PCLK = ~PCLK;
  
  //---------------------------------------
  //reset Generation
  //---------------------------------------
  initial begin
    PCLK = 0;
    PRESETn = 0;
    #20 PRESETn =1;
  end
  
  //---------------------------------------
  //APB interface instance
  //---------------------------------------
  //mem_if intf(clk,reset);
  apb_if intf(.PCLK(PCLK), .PRESETn(PRESETn));
  
  //---------------------------------------
  //DUT instance
  //---------------------------------------

  apb_wrapper #(
                .ADDR_W(32),
                .DATA_W(64),
                .MEM_SIZE_K(64),
                .BASE_ADDR(0)
  )

  DUT (
      .PCLK(PCLK),
      .PRESETn(PRESETn),
      .PSELx(intf.PSELx),
      .PENABLE(intf.PENABLE),
      .PWRITE(intf.PWRITE),
      .PWDATA(intf.PWDATA),
      .PSTRB(intf.PSTRB),
      .PADDR(intf.PADDR),
      .PRDATA(intf.PRDATA),
      .PREADY(intf.PREADY),
      .PSLVERR(intf.PSLVERR)
   );
  
  //---------------------------------------
  //passing the interface handle to lower heirarchy using set method 
  //and enabling the wave dump
  //---------------------------------------
  initial begin 
    uvm_config_db#(virtual apb_if)::set(uvm_root::get(),"*","vif",intf);
    //enable wave dump
    // $dumpfile("dump.vcd"); 
    // $dumpvars;

    $vcdplusfile("waveform.vpd"); 
    $vcdpluson;
  end
  
  //---------------------------------------
  //calling test
  //---------------------------------------
  initial begin 
    run_test("apb_wr_rd_test");
  end
  
endmodule