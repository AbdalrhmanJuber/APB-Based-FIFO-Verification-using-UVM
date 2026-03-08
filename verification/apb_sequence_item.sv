class apb_item extends uvm_sequence_item;
  `uvm_object_utils(apb_item)

  rand bit        write;        // 1=WRITE, 0=READ
  rand bit [7:0]  addr;
  rand bit [31:0] wdata;

  bit  [31:0]     rdata;
  bit             slverr;
  bit             ok;

  constraint c_addr { addr inside {8'h00,8'h04,8'h08,8'h0C}; }

  function new(string name="apb_item");
    super.new(name);
  endfunction

  function string convert2string();
    return $sformatf("APB %s addr=0x%02h wdata=0x%08h rdata=0x%08h ok=%0d slverr=%0d",
                     write ? "WRITE" : "READ", addr, wdata, rdata, ok, slverr);
  endfunction
endclass
