class apb_full_test extends apb_base_test;
    `uvm_component_utils(apb_full_test)

    apb_base_seq     random_seq;
    wr_rd_seq        wr_rd_seq_h;
    apb_err_seq      err_seq;
    apb_boundary_seq bnd_seq;

    function new(string name="apb_full_test", uvm_component c);
        super.new(name, c);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        random_seq   = apb_base_seq::type_id::create("random_seq");
        wr_rd_seq_h  = wr_rd_seq::type_id::create("wr_rd_seq_h");
        err_seq      = apb_err_seq::type_id::create("err_seq");
        bnd_seq      = apb_boundary_seq::type_id::create("bnd_seq");
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        `uvm_info(get_type_name(), "=== Running RANDOM ===", UVM_LOW)
        random_seq.start(env.apb_agnt.sequencer);

        `uvm_info(get_type_name(), "=== Running WR_RD ===", UVM_LOW)
        wr_rd_seq_h.start(env.apb_agnt.sequencer);

        `uvm_info(get_type_name(), "=== Running ERROR ===", UVM_LOW)
        err_seq.start(env.apb_agnt.sequencer);

        `uvm_info(get_type_name(), "=== Running BOUNDARY ===", UVM_LOW)
        bnd_seq.start(env.apb_agnt.sequencer);

        phase.drop_objection(this);
    endtask
endclass
