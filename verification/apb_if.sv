interface apb_if (input logic PCLK);
  logic        PRESETn;
  logic        PSEL;
  logic        PENABLE;
  logic        PWRITE;
  logic [7:0]  PADDR;
  logic [31:0] PWDATA;
  logic [31:0] PRDATA;
  logic        PREADY;
  logic        PSLVERR;

  modport drv (output PSEL, PENABLE, PWRITE, PADDR, PWDATA,
               input  PRDATA, PREADY, PSLVERR, PRESETn, PCLK);
  modport mon (input  PSEL, PENABLE, PWRITE, PADDR, PWDATA,
               input  PRDATA, PREADY, PSLVERR, PRESETn, PCLK);
endinterface
