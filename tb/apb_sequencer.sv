//-------------------------------------------------------------------------
//						apb_sequencer 
//-------------------------------------------------------------------------

class apb_sequencer extends uvm_sequencer#(apb_seq_item);

  `uvm_component_utils(apb_sequencer) 

  //---------------------------------------
  //constructor
  //---------------------------------------
  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(),"UVM_Sequencer Build_Phase",UVM_LOW);
  endfunction
endclass