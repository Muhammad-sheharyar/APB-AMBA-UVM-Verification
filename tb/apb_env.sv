//-------------------------------------------------------------------------
//						mem_env - www.verificationguide.com
//-------------------------------------------------------------------------

// `include "mem_agent.sv"
// `include "mem_scoreboard.sv"

class apb_env extends uvm_env;
  
  //---------------------------------------
  // agent and scoreboard instance
  //---------------------------------------
  apb_agent      apb_agnt;
  apb_scoreboard apb_scb;
  apb_coverage   apb_cov;
  
  `uvm_component_utils(apb_env)
  
  //--------------------------------------- 
  // constructor
  //---------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //---------------------------------------
  // build_phase - crate the components
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(),"UVM_ENV Build_Phase Started",UVM_LOW);
    apb_agnt = apb_agent::type_id::create("apb_agnt", this);
    apb_scb  = apb_scoreboard::type_id::create("apb_scb", this);
    apb_cov  = apb_coverage::type_id::create("apb_cov", this);
  endfunction : build_phase
  
  //---------------------------------------
  // connect_phase - connecting monitor and scoreboard port
  //---------------------------------------
  function void connect_phase(uvm_phase phase);
    `uvm_info(get_type_name(),"UVM_ENV Connect_Phase Started",UVM_LOW);
    apb_agnt.monitor.item_collected_port.connect(apb_scb.item_collected_export);
     // Monitor → Coverage (NEW)
     apb_agnt.monitor.item_collected_port.connect(apb_cov.analysis_export);
  endfunction : connect_phase

endclass : apb_env