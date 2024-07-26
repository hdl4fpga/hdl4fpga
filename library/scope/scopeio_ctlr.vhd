
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.hdo.all;
use hdl4fpga.scopeiopkg.all;
use hdl4fpga.cgafonts.all;

entity scopeio_ctlr is
	port (
		exit_req  : in  std_logic;
		exit_rdy  : out std_logic;
		next_req  : in  std_logic;
		next_rdy  : out std_logic;
		prev_req  : in  std_logic;
		prev_rdy  : out std_logic;
		enter_req : in  std_logic;
		enter_rdy : out std_logic;

		so_frm    : out std_logic;
		so_irdy   : out std_logic;
		so_trdy   : in  std_logic := '0';
		so_data   : out std_logic_vector);


end;

architecture def of scopeio_ctlr is
begin

	vtoffsets_e : entity hdl4fpga.dpram
	port map (
		wr_clk  => rgtr_clk,
		wr_ena  => vtoffset_ena,
		wr_addr => vt_offsetcid,
		wr_data => vtl_offset,
		rd_addr => vtl_scalecid,
		rd_data => tbl_offset);

	vtscales_e : entity hdl4fpga.dpram
	port map (
		wr_clk  => rgtr_clk,
		wr_ena  => vtscale_ena,
		wr_addr => vt_scalecid,
		wr_data => vt_scaleid,
		rd_addr => vt_scalecid,
		rd_data => vt_scaleid);

	triggers_e : entity hdl4fpga.dpram
	port map (
		wr_clk  => rgtr_clk,
		wr_ena  => vtscale_ena,
		wr_addr => vt_scalecid,
		wr_data => vt_scaleid,
		rd_addr => vt_scalecid,
		rd_data => vt_scaleid);

end;
