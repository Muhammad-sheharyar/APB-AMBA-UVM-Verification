class apb_coverage extends uvm_subscriber #(apb_seq_item);
    `uvm_component_utils(apb_coverage)

    // Transaction handle
    apb_seq_item tx;

    // ============================================================
    // COVERGROUP
    // ============================================================
    covergroup apb_cg;
        option.per_instance = 1;
        option.name = "apb_functional_coverage";

        // ---------- 1. WRITE / READ ----------
        cp_write : coverpoint tx.write {
            bins WRITE = {1};
            bins READ  = {0};
        }

        // ---------- 2. STROBE PATTERNS ----------
        cp_strb : coverpoint tx.strb {
            bins ALL_ONES  = {8'hFF};
            bins UPPER_4B  = {8'hF0};
            bins LOWER_4B  = {8'h0F};
            bins BYTE0     = {8'h01};
            bins BYTE7     = {8'h80};
            bins ALT_55    = {8'h55};
            bins ALT_AA    = {8'hAA};
            bins ZERO      = {8'h00};
            bins OTHERS    = default;
        }

        // ---------- 3. ADDRESS REGIONS ----------
        cp_addr : coverpoint tx.addr {
            bins LOW       = {[32'h0000_0000 : 32'h0000_00FF]};
            bins MID       = {[32'h0000_0100 : 32'h0000_7FFF]};
            bins HIGH      = {[32'h0000_8000 : 32'h0000_FFF8]};
            bins OOB       = {[32'h0001_0000 : 32'hFFFF_FFFF]};
            bins LOWER_BND = {32'h0000_0000};
            bins UPPER_BND = {32'h0000_FFF8};
        }

        // ---------- 4. ADDRESS ALIGNMENT ----------
        cp_align : coverpoint (tx.addr % 8) {
            bins ALIGNED   = {0};
            bins MISALIGN  = {[1:7]};
        }

        // ---------- 5. DATA PATTERNS ----------
        cp_data : coverpoint tx.wdata {
            bins ZERO      = {64'h0};
            bins ALL_ONES  = {64'hFFFF_FFFF_FFFF_FFFF};
            bins PAT_AAAA  = {64'hAAAA_AAAA_AAAA_AAAA};
            bins PAT_5555  = {64'h5555_5555_5555_5555};
            bins OTHERS    = default;
        }

        // ---------- 6. PSLVERR ----------
        cp_pslverr : coverpoint tx.pslverr {
            bins NO_ERR = {0};
            bins ERR    = {1};
        }

        // ============================================================
        // CROSS COVERAGE
        // ============================================================

        // Cross 1: Write × Strobe
        cx_write_strb : cross cp_write, cp_strb;

        // Cross 2: Write × PSLVERR
        cx_write_err : cross cp_write, cp_pslverr;

        // Cross 3: Address region × Data pattern
        cx_addr_data : cross cp_addr, cp_data {
            // Sirf relevant combinations (kuch bins ignore karo)
            ignore_bins ignore_oob_data =
                binsof(cp_addr.OOB) && binsof(cp_data.OTHERS);
        }

        // Cross 4: Alignment × PSLVERR
        cx_align_err : cross cp_align, cp_pslverr;

    endgroup

    // ============================================================
    // CONSTRUCTOR
    // ============================================================
    function new(string name, uvm_component parent);
        super.new(name, parent);
        apb_cg = new();
    endfunction

    // ============================================================
    // write() — uvm_subscriber yeh call karta hai
    // ============================================================
    function void write(apb_seq_item t);
    `uvm_info(get_type_name(), "WRITE CALLED", UVM_LOW)
        tx = t;
        apb_cg.sample();
    endfunction

    // ============================================================
    // report_phase — Coverage summary
    // ============================================================
    function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_type_name(), "REPORT PHASE CALLED", UVM_NONE)
        `uvm_info(get_type_name(),
    $sformatf("\n===== FUNCTIONAL COVERAGE =====\nOverall: %.2f%%",
             apb_cg.get_coverage()), UVM_NONE)
    endfunction

endclass