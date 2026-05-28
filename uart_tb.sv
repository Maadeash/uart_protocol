`timescale 1ns/1ps

interface uart_if(input logic clk);
  logic rst;
  logic [7:0]w_data;
  logic wr;
  logic rd;
  wire tx;
  wire rx;
  wire tx_full;
  wire rx_empty;
  wire [7:0]r_data;
  
  clocking drv_cb @(posedge clk);
    default input #1 output #1;
    output w_data;
    output wr;
    output rd;
    input tx_full;
    input rx_empty;
    input r_data;
  endclocking
  
  clocking mon_cb @(posedge clk);
    default input #1;
    input w_data;
    input wr;
    input rd;
    input tx;
    input rx;
    input tx_full;
    input rx_empty;
    input r_data;
  endclocking
  
  modport DRV(clocking drv_cb,input clk,ref rst);
  modport MON(clocking mon_cb,input clk,input rst);
endinterface

class uart_transaction;
  rand bit [7:0]data;
  
  function void display(string tag);
    $display("[%0t][%s] DATA=0x%02h",$time,tag,data);
  endfunction
endclass

class uart_generator;
  mailbox #(uart_transaction)gen2drv;
  int num_trans;
  
  function new(mailbox #(uart_transaction)mb,int n=10);
    gen2drv=mb;
    num_trans=n;
  endfunction
  
  task run();
    uart_transaction tr;
    
    repeat(num_trans)
      begin
        tr=new();
        assert(tr.randomize()) else $fatal(1,"Randomize failed");
        tr.display("GEN");
        gen2drv.put(tr);
      end
  endtask
endclass

class uart_driver;
  virtual uart_if vif;
  mailbox #(uart_transaction)gen2drv;
  mailbox #(uart_transaction)drv2scb;
  
  function new(
    virtual uart_if v,
    mailbox #(uart_transaction)g2d,
    mailbox #(uart_transaction)d2s
  );
    vif=v;
    gen2drv=g2d;
    drv2scb=d2s;
  endfunction
  
  task write_byte(input [7:0]data);
    @(posedge vif.clk);
    
    while(vif.tx_full)
      @(posedge vif.clk);
      
    @(posedge vif.clk);
    vif.w_data=data;
    vif.wr=1'b1;
    
    @(posedge vif.clk);
    vif.wr=1'b0;
    vif.w_data=8'h00;
  endtask
  
  task read_byte();
    @(posedge vif.clk);
    
    while(vif.rx_empty)
      @(posedge vif.clk);
      
    @(posedge vif.clk);
    vif.rd=1'b1;
    
    @(posedge vif.clk);
    vif.rd=1'b0;
  endtask
  
  task run();
    uart_transaction tr;
    
    vif.wr=1'b0;
    vif.rd=1'b0;
    vif.w_data=8'h00;
    
    forever
      begin
        gen2drv.get(tr);
        write_byte(tr.data);
        
        $display("[%0t][DRV] WROTE 0x%02h",$time,tr.data);
        
        drv2scb.put(tr);
        
        read_byte();
      end
  endtask
endclass

class uart_monitor;
  virtual uart_if vif;
  mailbox #(uart_transaction)mon2scb;
  
  function new(
    virtual uart_if v,
    mailbox #(uart_transaction)m2s
  );
    vif=v;
    mon2scb=m2s;
  endfunction
  
  task run();
    uart_transaction tr;
    
    forever
      begin
        @(posedge vif.clk iff(vif.rd===1'b1));
        
        @(posedge vif.clk);
        
        tr=new();
        tr.data=vif.r_data;
        
        mon2scb.put(tr);
        
        $display("[%0t][MON] CAPTURED 0x%02h",$time,tr.data);
      end
  endtask
endclass

class uart_scoreboard;
  mailbox #(uart_transaction)drv2scb;
  mailbox #(uart_transaction)mon2scb;
  
  bit [7:0]exp_q[$];
  
  int pass_cnt,fail_cnt;
  
  function new(
    mailbox #(uart_transaction)d2s,
    mailbox #(uart_transaction)m2s
  );
    drv2scb=d2s;
    mon2scb=m2s;
    pass_cnt=0;
    fail_cnt=0;
  endfunction
  
  task run();
    uart_transaction tr;
    
    fork
      forever
        begin
          drv2scb.get(tr);
          exp_q.push_back(tr.data);
          
          $display("[%0t][SCB] EXPECT 0x%02h (queue depth=%0d)",
          $time,tr.data,exp_q.size());
        end
        
      forever
        begin
          bit [7:0]exp;
          
          mon2scb.get(tr);
          
          if(exp_q.size()>0)
            begin
              exp=exp_q.pop_front();
              
              if(exp===tr.data)
                begin
                  $display("[%0t][SCB] PASS EXP=0x%02h ACT=0x%02h",
                  $time,exp,tr.data);
                  
                  pass_cnt++;
                end
              else
                begin
                  $display("[%0t][SCB] FAIL EXP=0x%02h ACT=0x%02h",
                  $time,exp,tr.data);
                  
                  fail_cnt++;
                end
            end
          else
            begin
              $display("[%0t][SCB] FAIL UNEXPECTED ACT=0x%02h",
              $time,tr.data);
              
              fail_cnt++;
            end
        end
    join
  endtask
  
  function void report();
    $display(" SCOREBOARD SUMMARY: PASS=%0d FAIL=%0d",pass_cnt,fail_cnt);
  endfunction
endclass

class uart_coverage;
  uart_transaction tr;
  
  covergroup uart_cg;
    DATA:coverpoint tr.data
      {
        bins LOW={[8'h00:8'h3F]};
        bins MID={[8'h40:8'hAF]};
        bins HIGH={[8'hB0:8'hFF]};
      }
  endgroup
  
  function new();
    uart_cg=new();
  endfunction
  
  task sample(uart_transaction t);
    tr=t;
    uart_cg.sample();
  endtask
endclass

module uart_assertions(uart_if vif);

  property tx_idle_after_reset;
    @(posedge vif.clk) vif.rst |-> ##1(vif.tx===1'b1);
  endproperty
  
  assert property(tx_idle_after_reset)
    else $error("[ASSERT] TX not HIGH after reset at %0t",$time);

  property rx_empty_after_reset;
    @(posedge vif.clk) vif.rst |-> ##1(vif.rx_empty===1'b1);
  endproperty
  
  assert property(rx_empty_after_reset)
    else $error("[ASSERT] RX FIFO not empty after reset at %0t",$time);

  property tx_not_full_after_reset;
    @(posedge vif.clk) vif.rst |-> ##1(vif.tx_full===1'b0);
  endproperty
  
  assert property(tx_not_full_after_reset)
    else $error("[ASSERT] TX FIFO full after reset at %0t",$time);

endmodule

module tb_uart_vip;

  logic clk=0;
  
  always #5 clk=~clk;
  
  uart_if vif(.clk(clk));
  
  top #(
    .dbit(8),
    .sb_tck(16),
    .n(10),
    .m(651),
    .fifo_addbit(2)
  ) dut (
    .clk(clk),
    .rst(vif.rst),
    .w_data(vif.w_data),
    .rd(vif.rd),
    .wr(vif.wr),
    .rx(vif.rx),
    .tx(vif.tx),
    .tx_full(vif.tx_full),
    .rx_empty(vif.rx_empty),
    .r_data(vif.r_data)
  );
  
  assign vif.rx=vif.tx;
  
  uart_assertions ua(vif);
  
  mailbox #(uart_transaction)gen2drv=new();
  mailbox #(uart_transaction)drv2scb=new();
  mailbox #(uart_transaction)mon2scb=new();
  
  uart_generator gen;
  uart_driver drv;
  uart_monitor mon;
  uart_scoreboard scb;
  uart_coverage cov;
  
  localparam SIM_TIME_NS=15000000;
  
  initial
    begin
      gen=new(gen2drv,10);
      drv=new(vif,gen2drv,drv2scb);
      mon=new(vif,mon2scb);
      scb=new(drv2scb,mon2scb);
      cov=new();
      
      vif.rst=1'b1;
      vif.wr=1'b0;
      vif.rd=1'b0;
      vif.w_data=8'h00;
      
      repeat(20)
        @(posedge clk);
        
      vif.rst=1'b0;
      
      @(posedge clk);
      
      $display("[%0t][TB] Reset released - starting test",$time);
      
      fork
        gen.run();
        drv.run();
        mon.run();
        scb.run();
      join_none
      
      fork
        begin
          uart_transaction ct;
          
          repeat(10)
            begin
              drv2scb.peek(ct);
              cov.sample(ct);
              #500;
            end
        end
      join_none
      
      #SIM_TIME_NS;
      
      scb.report();
      
      $display("[%0t][TB] Simulation complete",$time);
      
      $finish;
    end
    
  initial
    begin
      $dumpfile("uart_sim.vcd");
      $dumpvars(0,tb_uart_vip);
    end
    
endmodule
