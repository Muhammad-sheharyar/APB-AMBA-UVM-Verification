//-------------------------------------------------------------------------
//						apb_interface
//-------------------------------------------------------------------------

// ---------- Interface ----------
interface apb_if(input logic PCLK, input logic PRESETn);

  //---------------------------------------
  //declaring the signals
  //---------------------------------------
    //logic         PRESETn;
    logic         PSELx;
    logic         PENABLE;
    logic         PWRITE;
    logic [31:0]  PADDR;
    logic [63:0]  PWDATA;
    logic [7:0]   PSTRB;
    logic [63:0]  PRDATA;
    logic         PREADY;
    logic         PSLVERR;

  // ---------------------------------------
  // driver clocking block
  // ---------------------------------------

    clocking drv_cb @(posedge PCLK);
        default input #1step output #1;
        output PSELx, PENABLE, PWRITE, PADDR, PWDATA, PSTRB;
        input  PRDATA, PREADY, PSLVERR;
    endclocking

  //---------------------------------------
  //monitor clocking block
  //---------------------------------------
    clocking mon_cb @(posedge PCLK);
        default input #1step;
        input PSELx, PENABLE, PWRITE, PADDR, PWDATA, PSTRB;
        input PRDATA, PREADY, PSLVERR;
    endclocking
  
  //---------------------------------------
  //driver modport
  //---------------------------------------
  modport DRIVER  (clocking drv_cb,input PCLK);
  
  //---------------------------------------
  //monitor modport  
  //---------------------------------------
  modport MONITOR (clocking mon_cb,input PCLK);

endinterface
