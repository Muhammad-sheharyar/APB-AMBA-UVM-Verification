class apb_err_seq extends uvm_sequence #(apb_seq_item);
    `uvm_object_utils(apb_err_seq)

    function new(string name="apb_err_seq"); super.new(name); endfunction

    task body();
        apb_seq_item tr;

        // ---- Out of bounds (0x10000 se bahar) ----
        for (int i = 0; i < 4; i++) begin
            tr = apb_seq_item::type_id::create("tr");
            start_item(tr);
            tr.addr  = 32'h0001_0000 + (i * 8);
            tr.write = 1;
            tr.strb  = 8'hFF;
            tr.wdata = $urandom;
            finish_item(tr);
        end

        // ---- Misaligned (8-byte aligned nahi) ----
        for (int i = 1; i < 8; i++) begin
            tr = apb_seq_item::type_id::create("tr");
            start_item(tr);
            tr.addr  = i;             // 1,2,3,4,5,6,7
            tr.write = 1;
            tr.strb  = 8'hFF;
            tr.wdata = $urandom;
            finish_item(tr);
        end

        // ---- Upper invalid ----
        tr = apb_seq_item::type_id::create("tr");
        start_item(tr);
        tr.addr  = 32'hFFFF_FFF8;
        tr.write = 0;
        tr.strb  = 8'h00;
        finish_item(tr);

        // ---- Kuch valid transfers bhi ----
        for (int i = 0; i < 7; i++) begin
            tr = apb_seq_item::type_id::create("tr");
            start_item(tr);
            tr.addr  = i * 8;
            tr.write = i % 2;
            tr.strb  = (i % 2) ? 8'hFF : 8'h00;
            tr.wdata = $urandom;
            finish_item(tr);
        end
    endtask
endclass