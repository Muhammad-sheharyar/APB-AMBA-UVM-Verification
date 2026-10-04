//-------------------------------------------------------------------------
//						mem_agent - www.verificationguide.com 
//-------------------------------------------------------------------------

// `include "mem_seq_item.sv"
// `include "mem_sequencer.sv"
// `include "mem_sequence.sv"
// `include "mem_driver.sv"
// `include "mem_monitor.sv"

class apb_agent extends uvm_agent;

  //---------------------------------------
  // component instances
  //---------------------------------------
  apb_driver    driver;
  apb_sequencer sequencer;
  apb_monitor   monitor;

  `uvm_component_utils(apb_agent)
  
  //---------------------------------------
  // constructor
  //---------------------------------------
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //---------------------------------------
  // build_phase
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    `uvm_info(get_type_name(),"UVM_AGENT Build_Phase Started",UVM_LOW);    
    monitor = apb_monitor::type_id::create("monitor", this);

    //creating driver and sequencer only for ACTIVE agent
    if(get_is_active() == UVM_ACTIVE) begin
      driver    = apb_driver::type_id::create("driver", this);
      sequencer = apb_sequencer::type_id::create("sequencer", this);
    end
  endfunction : build_phase
  
  //---------------------------------------  
  // connect_phase - connecting the driver and sequencer port
  //---------------------------------------
  function void connect_phase(uvm_phase phase);
    `uvm_info(get_type_name(),"UVM_AGENT Connect_Phase Started",UVM_LOW);
    if(get_is_active() == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
  endfunction : connect_phase

endclass : apb_agent