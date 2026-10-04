class wr_rd_seq extends uvm_sequence #(apb_seq_item);
    `uvm_object_utils(wr_rd_seq)

    function new(string name="wr_rd_seq"); super.new(name); endfunction

    task body();
        apb_seq_item wr, rd;
        bit [31:0] target_addr;
        bit [63:0] target_data;

        repeat (20) begin
            // 8-byte aligned address (0 se 0xFFF8 tak, step 8)
            target_addr = ($urandom_range(0, 8191)) * 8;   // 0..65528, aligned
            target_data = {$urandom, $urandom};

            // 2) WRITE karo us address pe (full strb)
            wr = apb_seq_item::type_id::create("wr");
            start_item(wr);
            wr.addr  = target_addr;
            wr.write = 1;
            wr.strb  = 8'hFF;              // full 8-byte write
            wr.wdata = target_data;
            finish_item(wr);

            // 3) READ karo SAME address se
            rd = apb_seq_item::type_id::create("rd");
            start_item(rd);
            rd.addr  = target_addr;
            rd.write = 0;
            rd.strb  = 8'h00;
            finish_item(rd);

            `uvm_info(get_type_name(),
                $sformatf("WR→RD addr=0x%08h exp=0x%016h got=0x%016h",
                         target_addr, target_data, rd.rdata), UVM_LOW)
        end
    endtask
endclass