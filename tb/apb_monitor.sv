//-------------------------------------------------------------------------
//						apb_monitor
//-------------------------------------------------------------------------

class apb_monitor extends uvm_monitor;

    `uvm_component_utils(apb_monitor)

    // Virtual interface
    virtual apb_if vif;

    // Analysis port (scoreboard ko bhejne ke liye)
    uvm_analysis_port #(apb_seq_item) item_collected_port;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        item_collected_port = new("item_collected_port", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif))
            `uvm_fatal(get_type_name(), "No vif in monitor")
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever collect_one_transfer();
    endtask

    // -------- Helper: ek complete APB transfer capture karo --------
    virtual task collect_one_transfer();
        apb_seq_item tx;
        bit          started = 0;

        // 1) Wait for SETUP: PSELx=1, PENABLE=0
        while (!started) begin
            @(vif.mon_cb);
            if (vif.mon_cb.PSELx === 1'b1 && vif.mon_cb.PENABLE === 1'b0)
                started = 1;
        end

        // 2) SETUP ke signals pakdo
        tx = apb_seq_item::type_id::create("mon_tx");
        tx.addr  = vif.mon_cb.PADDR;
        tx.write = vif.mon_cb.PWRITE;
        tx.strb  = vif.mon_cb.PSTRB;
        if (vif.mon_cb.PWRITE)
            tx.wdata = vif.mon_cb.PWDATA;

        // 3) Wait for ACCESS + PREADY=1 (transfer complete)
        do @(vif.mon_cb);
        while (!(vif.mon_cb.PSELx   === 1'b1 &&
                 vif.mon_cb.PENABLE === 1'b1 &&
                 vif.mon_cb.PREADY  === 1'b1));

        // 4) Completion ke signals pakdo
        tx.pselx   = vif.mon_cb.PSELx;
        tx.penable = vif.mon_cb.PENABLE;
        tx.pready  = vif.mon_cb.PREADY;
        tx.prdata  = vif.mon_cb.PRDATA;
        tx.rdata   = vif.mon_cb.PRDATA;
        tx.pslverr = vif.mon_cb.PSLVERR;

        // 5) Scoreboard ko bhejo
        `uvm_info(get_type_name(),
            $sformatf("[MON] %s addr=0x%08h data=0x%016h strb=0x%02h rdata=0x%016h err=%0b",
                     tx.write ? "WR " : "RD ", tx.addr,
                     tx.write ? tx.wdata : tx.rdata,
                     tx.strb, tx.rdata, tx.pslverr), UVM_MEDIUM);

        item_collected_port.write(tx);
    endtask

endclass