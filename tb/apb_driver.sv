//-------------------------------------------------------------------------
//						apb_driver
//-------------------------------------------------------------------------

`define DRIV_IF vif.DRIVER.drv_cb

class apb_driver extends uvm_driver #(apb_seq_item);

  //--------------------------------------- 
  // Virtual Interface
  //--------------------------------------- 
  virtual apb_if vif;
  `uvm_component_utils(apb_driver)
    
  //--------------------------------------- 
  // Constructor
  //--------------------------------------- 
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //--------------------------------------- 
  // build phase
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(),"UVM_DRIVER Build_Phase Started",UVM_LOW);
    if(!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif))
       `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction: build_phase

  //---------------------------------------  
  // run phase
  //---------------------------------------  
  virtual task run_phase(uvm_phase phase);
    `uvm_info(get_type_name(),"UVM_DRIVER Run_Phase Started",UVM_LOW);
        // === RESET WAIT ===
    wait(vif.PRESETn === 1'b1);
    @(posedge vif.PCLK);   // ek extra edge safety ke liye

    forever begin
      seq_item_port.get_next_item(req);
      drive();
      `uvm_info(get_type_name(),$sformatf("Driving Transaction: addr=%0h write=%0d wdata = %0h",req.addr, req.write, req.wdata),UVM_LOW);
      seq_item_port.item_done();
    end
  endtask : run_phase
  
  //---------------------------------------
  // drive - transaction level to signal level
  // drives the value's from seq_item to interface signals
  //---------------------------------------

virtual task drive();
    // ================== SETUP PHASE ==================
    `DRIV_IF.PSELx   <= 1'b1;
    `DRIV_IF.PENABLE <= 1'b0;
    `DRIV_IF.PWRITE  <= req.write;
    `DRIV_IF.PADDR   <= req.addr;
    `DRIV_IF.PSTRB   <= req.write ? req.strb : 8'h00;
    if (req.write)
        `DRIV_IF.PWDATA <= req.wdata;
    // *** 2 edges wait karo taake DUT ko SETUP saaf dikhe ***
    @(posedge vif.DRIVER.PCLK);
    @(posedge vif.DRIVER.PCLK);   // <-- EXTRA edge

    // ================== ACCESS PHASE ==================
    `DRIV_IF.PENABLE <= 1'b1;

    // Wait for PREADY=1 (transfer complete)
    do @(posedge vif.DRIVER.PCLK);
    while (`DRIV_IF.PREADY !== 1'b1);

    // Capture read data / error for read transfers
    if (!req.write) begin
        req.rdata = `DRIV_IF.PRDATA;
    end
    req.pslverr = `DRIV_IF.PSLVERR;

    // ================== DEASSERT ==================
    `DRIV_IF.PSELx   <= 1'b0;
    `DRIV_IF.PENABLE <= 1'b0;
    `DRIV_IF.PWRITE  <= 1'b0;
endtask

endclass : apb_driver