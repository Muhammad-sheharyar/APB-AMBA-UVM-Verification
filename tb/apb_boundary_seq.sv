class apb_boundary_seq extends uvm_sequence #(apb_seq_item);
    `uvm_object_utils(apb_boundary_seq)

    function new(string name="apb_boundary_seq"); super.new(name); endfunction

    task body();
        apb_seq_item tr;

        // Lower boundary 0x0 pe write
        tr = apb_seq_item::type_id::create("tr");
        start_item(tr);
        tr.addr  = 32'h0000_0000;
        tr.wdata = 64'h1234_5678_9ABC_DEF0;
        tr.write = 1; tr.strb = 8'hFF;
        finish_item(tr);

        // Upper boundary 0xFFF8 pe write
        tr = apb_seq_item::type_id::create("tr");
        start_item(tr);
        tr.addr  = 32'h0000_FFF8;
        tr.wdata = 64'hDEAD_BEEF_CAFE_1234;
        tr.write = 1; tr.strb = 8'hFF;
        finish_item(tr);

        // Lower boundary read
        tr = apb_seq_item::type_id::create("tr");
        start_item(tr);
        tr.addr  = 32'h0000_0000;
        tr.write = 0; tr.strb = 8'h00;
        finish_item(tr);

        // Upper boundary read
        tr = apb_seq_item::type_id::create("tr");
        start_item(tr);
        tr.addr  = 32'h0000_FFF8;
        tr.write = 0; tr.strb = 8'h00;
        finish_item(tr);
    endtask
endclass