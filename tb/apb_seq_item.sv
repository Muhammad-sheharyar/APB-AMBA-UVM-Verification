//-------------------------------------------------------------------------
//						apb_seq_item 
//-------------------------------------------------------------------------

class apb_seq_item extends uvm_sequence_item;

    static int count = 0;  //Saare objects share karte
    int id;		//Har object ka apna

    // APB fields
    rand bit [31:0]        addr;
    rand bit [63:0]        data;
    rand bit [63:0]        wdata;
    rand bit               write;
    rand bit [7:0]         strb;

    // Coverage ke liye. monitor inko capture kry ga // y rand nhi hai kion keh monitor inko assign krta hai
    bit                    pselx;      // PSELx at transfer
    bit                    penable;    // PENABLE at transfer
    bit                    pready;     // PREADY at transfer
    bit [63:0]             prdata;     // PRDATA (captured)

    // Error tracking
    bit                    err_expected;

    // Captured response
    bit [63:0]             rdata;
    bit                    pslverr;

  //---------------------------------------
  //Utility and Field macros
  //---------------------------------------
`uvm_object_utils_begin(apb_seq_item)
    `uvm_field_int(addr,UVM_ALL_ON)
    `uvm_field_int(data,UVM_ALL_ON)
    `uvm_field_int(write,UVM_ALL_ON)
    `uvm_field_int(strb,UVM_ALL_ON)

    `uvm_field_int(pselx,UVM_ALL_ON)
    `uvm_field_int(penable,UVM_ALL_ON)
    `uvm_field_int(pready,UVM_ALL_ON)
    `uvm_field_int(prdata,UVM_ALL_ON)
    `uvm_field_int(err_expected,UVM_ALL_ON)
    `uvm_field_int(rdata,UVM_ALL_ON)
    `uvm_field_int(pslverr,UVM_ALL_ON)
`uvm_object_utils_end
  
  //---------------------------------------
  //Constructor
  //---------------------------------------
  function new(string name = "apb_seq_item");
    super.new(name);
  endfunction

    // ============================================================
    // CONSTRAINTS
    // ============================================================

    constraint addr_range_c {
        addr >= 32'h0000_0000;
        addr <= 32'h0000_FFF8;
        addr[2:0] == 3'b000;   // lower 3 bits zero honi zarori hai.
    }

    constraint write_dist_c {
        write dist { 1'b1 := 50, 1'b0 := 50 };
    }

    constraint strobe_c {
        if (write) {
            strb dist {
                8'hFF           := 15, //full write
                8'h0F           := 10, //lower 4 byte
                8'hF0           := 10, //upper 4 byte
                8'h01           := 10, // byte 0 only
                8'h80           := 10, //byte 7 only
                8'h55           := 10, //01010101
                8'hAA           := 10, //10101010
                8'h33           := 5,  //mixed
                8'hCC           := 5,
                8'h11           := 5,
                8'h22           := 5,
                8'h44           := 5,
                8'h88           := 5,
                [8'h01:8'hFE]   := 5
            };
        } else {
            strb == 8'h00;
        }
    }

    constraint data_dist_c {
        data dist {
            64'h0000_0000_0000_0000  := 10,
            64'hFFFF_FFFF_FFFF_FFFF  := 10,
            64'hAAAA_AAAA_AAAA_AAAA  := 10,
            64'h5555_5555_5555_5555  := 10,
            64'h0123_4567_89AB_CDEF  := 5,
            64'hFEDC_BA98_7654_3210  := 5,
            64'h8000_0000_0000_0000  := 5,
            64'h0000_0000_0000_0001  := 5,
            [64'h1:64'hFFFF_FFFF_FFFF_FFFE] := 35
        };
    }

    // function new();
    //     id = -1;  //unassigned marker hai
    //     err_expected = 1'b0;
    //     pselx = 0;
    //     penable = 0;
    //     pready = 0;
    //     prdata = 0;
    // endfunction

    // function void assign_id();
    //     id = count;
    //     count++;
    // endfunction

    // function void display(string caller = "[TX]");
    //     $display("%s ID=%0d | %s | addr=0x%08h
    //      data=0x%016h strb=0x%02h | err_exp=%0b",
    //              caller, id, write ? "WRITE" : "READ ",
    //              addr, data, strb, err_expected);
    // endfunction

    // function apb_transaction copy();
    //     apb_transaction t = new();
    //     t.id           = this.id;
    //     t.addr         = this.addr;
    //     t.data         = this.data;
    //     t.write        = this.write;
    //     t.strb         = this.strb;
    //     t.err_expected = this.err_expected;
    //     // ?? New fields bhi copy karein
    //     t.pselx        = this.pselx;
    //     t.penable      = this.penable;
    //     t.pready       = this.pready;
    //     t.prdata       = this.prdata;
    //     return t;
    // endfunction
 endclass