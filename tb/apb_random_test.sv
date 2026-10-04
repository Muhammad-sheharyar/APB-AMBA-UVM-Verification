//--------------- Random Test ---------------
class apb_random_test extends apb_base_test;
`uvm_component_utils(apb_random_test)
 apb_base_seq seq;

  //--------------------------------------- 
  //Constructor
  //--------------------------------------- 
function new(input string name = "apb_random_test", uvm_component c);
super.new(name,c);
endfunction
 
 
virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
`uvm_info(get_type_name(),"Test build phase", UVM_LOW);
seq = apb_base_seq::type_id::create("seq");
endfunction
 
task run_phase(uvm_phase phase);

phase.raise_objection(this);
`uvm_info(get_type_name(),"Test run phase", UVM_LOW)
seq.start(env.apb_agnt.sequencer);
phase.drop_objection(this);
`uvm_info(get_type_name(),"Test run phase: seq done", UVM_LOW);
endtask
endclass


