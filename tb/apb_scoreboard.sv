//-------------------------------------------------------------------------
//						apb_scoreboard 
//-------------------------------------------------------------------------

class apb_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(apb_scoreboard)

    // Analysis export — monitor yahan bhejega
    uvm_analysis_imp #(apb_seq_item, apb_scoreboard) item_collected_export;

    // -------- Reference Memory Model --------
    // DUT: byte-addressable, 64KB, 64-bit data
    bit [7:0]          ref_mem [bit [31:0]];

    // Stats
    int unsigned num_writes  = 0;
    int unsigned num_reads   = 0;
    int unsigned num_errors  = 0;

    // DUT parameters (err_gen se match karo)
    localparam int unsigned MEM_SIZE_B = 64 * 1024;   // 64KB
    localparam int unsigned ADDR_ALIGN = 8;           // 64-bit → 8-byte aligned

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        item_collected_export = new("item_collected_export", this);
    endfunction

    // -------- Expected Error Compute (err_gen se match) --------
    function bit is_expected_error(bit [31:0] addr);
        return (addr >= MEM_SIZE_B) || (addr % ADDR_ALIGN != 0);
    endfunction

    // -------- Reference Memory Update --------
    function void apply_write(apb_seq_item tx);
        for (int i = 0; i < 8; i++)
            if (tx.strb[i])
                ref_mem[tx.addr + i] = tx.wdata[i*8 +: 8];
    endfunction

    function bit [63:0] build_expected_read(bit [31:0] addr);
        bit [63:0] exp = 64'h0;
        for (int i = 0; i < 8; i++) begin
            if (ref_mem.exists(addr + i))
                exp[i*8 +: 8] = ref_mem[addr + i];
            else
                exp[i*8 +: 8] = 8'h00;   // uninitialized
        end
        return exp;
    endfunction

    // -------- write() — monitor jab bhi transfer bheje, yeh chalta hai --------
    virtual function void write(apb_seq_item tx);
        bit          exp_err;
        bit [63:0]   exp_data;
        
        bit exp_err = is_expected_error(tx.addr);

        // -------- Error check --------
        if (exp_err !== tx.pslverr) begin
            `uvm_error(get_type_name(),
                $sformatf("PSLVERR mismatch @addr=0x%08h : expected=%0b got=%0b",
                         tx.addr, exp_err, tx.pslverr))
        end

        if (exp_err) begin
            num_errors++;
            // Error case me DUT memory update nahi karta, isliye ref_mem bhi mat karo
            return;
        end

        if (tx.write) begin
            // =============== WRITE ===============
            num_writes++;
            apply_write(tx);
            `uvm_info(get_type_name(),
                $sformatf("[SCB] WR OK  addr=0x%08h wdata=0x%016h strb=0x%02h",
                         tx.addr, tx.wdata, tx.strb), UVM_LOW)
        end
        else begin
            // =============== READ ===============
            num_reads++;
            exp_data = build_expected_read(tx.addr);
            if (exp_data === tx.rdata)
                `uvm_info(get_type_name(),
                    $sformatf("[SCB] RD OK  addr=0x%08h exp=0x%016h got=0x%016h",
                             tx.addr, exp_data, tx.rdata), UVM_LOW)
            else
                `uvm_error(get_type_name(),
                    $sformatf("[SCB] RD FAIL addr=0x%08h exp=0x%016h got=0x%016h",
                             tx.addr, exp_data, tx.rdata))
        end
    endfunction

    // -------- Summary --------
    function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "================ SCOREBOARD SUMMARY ================", UVM_NONE)
        `uvm_info(get_type_name(), $sformatf("  WRITES = %0d", num_writes), UVM_NONE)
        `uvm_info(get_type_name(), $sformatf("  READS  = %0d", num_reads),  UVM_NONE)
        `uvm_info(get_type_name(), $sformatf("  ERRORS = %0d", num_errors), UVM_NONE)
        `uvm_info(get_type_name(), "====================================================", UVM_NONE)
    endfunction

endclass