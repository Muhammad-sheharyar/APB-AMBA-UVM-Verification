//---------- Direct Sequence Class like Generator_Class--------
class apb_base_seq extends uvm_sequence#(apb_seq_item);
    `uvm_object_utils(apb_base_seq)

  //--------------------------------------- 
  //Constructor
  //---------------------------------------
    function new(string name = "apb_base_seq");
      super.new(name);
    endfunction

  `uvm_declare_p_sequencer(apb_sequencer)

  //---------------------------------------
  // create, randomize and send the item to driver
  //---------------------------------------
  virtual task body();
   repeat(10) begin
    req = apb_seq_item::type_id::create("req");
    wait_for_grant();
    req.randomize();
    send_request(req);
    wait_for_item_done();
   end 
  endtask

endclass
//=========================================================================

//=========================================================================
// write_sequence - "write" type
//=========================================================================
class write_sequence extends uvm_sequence#(apb_seq_item);
  
  `uvm_object_utils(write_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "write_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    `uvm_do_with(req,{req.write==1;})
  endtask
endclass