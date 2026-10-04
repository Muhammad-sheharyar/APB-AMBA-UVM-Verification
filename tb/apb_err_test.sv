class apb_err_test extends apb_base_test;
    `uvm_component_utils(apb_err_test)
    apb_err_seq seq;

    function new(string name="apb_err_test", uvm_component c);
        super.new(name, c);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        seq = apb_err_seq::type_id::create("seq");
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        seq.start(env.apb_agnt.sequencer);
        phase.drop_objection(this);
    endtask
endclass