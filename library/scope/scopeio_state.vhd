
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.scopeiopkg.all;

entity scopeio_state is
	port (
		rgtr_clk  : in  std_logic;
		rgtr_dv   : in  std_logic;
		rgtr_id   : in  std_logic_vector(8-1 downto 0);
		rgtr_data : in  std_logic_vector);

end;

architecture def of scopeio_reading is

	signal vtscale_ena    : std_logic;
	signal vt_scalecid   : std_logic_vector(chanid_bits-1 downto 0);
	signal vt_cid         : std_logic_vector(chanid_bits-1 downto 0);
	signal vt_scaleid     : std_logic_vector(4-1 downto 0);
	signal tbl_scaleid    : std_logic_vector(vt_scaleid'range);

	signal vtoffset_ena   : std_logic;
	signal vt_offsetcid  : std_logic_vector(vt_cid'range);
	signal vt_offset     : std_logic_vector((5+8)-1 downto 0);
	signal tbl_offset     : std_logic_vector(vt_offset'range);

	signal trigger_ena    : std_logic;
	signal trigger_freeze : std_logic;
	signal trigger_slope  : std_logic;
	signal trigger_oneshot : std_logic;
	signal trigger_chanid : std_logic_vector(vt_cid'range);
	signal trigger_level  : std_logic_vector(unsigned_num_bits(grid_height)-1 downto 0);

	signal hz_ena         : std_logic;
	signal hz_scaleid     : std_logic_vector(4-1 downto 0);
	signal hztl_offset    : std_logic_vector(hzoffset_bits-1 downto 0);

begin

	hzaxis_e : entity hdl4fpga.scopeio_rgtrhzaxis
	port map (
		rgtr_clk  => rgtr_clk,
		rgtr_dv   => rgtr_dv,
		rgtr_id   => rgtr_id,
		rgtr_data => rgtr_data,

		hz_scale  => hz_scaleid,
		hz_offset => hzl_offset);

	vtscale_e : entity hdl4fpga.scopeio_rgtrvtscale
	generic map (
		rgtr      => false)
	port map (
		rgtr_clk  => rgtr_clk,
		rgtr_dv   => rgtr_dv,
		rgtr_id   => rgtr_id,
		rgtr_data => rgtr_data,

		vtscale_ena => vtscale_ena,
		vtchan_id   => vt_scalecid,
		vtscale_id  => vt_scaleid);

	vtoffset_e : entity hdl4fpga.scopeio_rgtrvtoffset
	generic map (
		rgtr      => false)
	port map (
		rgtr_clk  => rgtr_clk,
		rgtr_dv   => rgtr_dv,
		rgtr_id   => rgtr_id,
		rgtr_data => rgtr_data,

		vt_ena    => vtoffset_ena,
		vt_chanid => vt_offsetcid,
		vt_offset => vt_offset);

	tgr_e : entity hdl4fpga.scopeio_rgtrtrigger
	generic map (
		rgtr      => false)
	port map (
		rgtr_clk       => rgtr_clk,
		rgtr_dv        => rgtr_dv,
		rgtr_id        => rgtr_id,
		rgtr_data      => rgtr_data,

		trigger_ena    => trigger_ena,
		trigger_chanid => trigger_chanid,
		trigger_slope  => trigger_slope,
		trigger_oneshot => trigger_oneshot,
		trigger_freeze => trigger_freeze,
		trigger_level  => trigger_level);

	vtoffsets_e : entity hdl4fpga.dpram
	port map (
		wr_clk  => rgtr_clk,
		wr_ena  => vtoffset_ena,
		wr_addr => vt_offsetcid,
		wr_data => vtl_offset,
		rd_addr => vtl_scalecid,
		rd_data => tbl_offset);

	vt_cid <= 
		vt_offsetcid  when vtoffset_ena='1' else 
		trigger_chanid when  trigger_ena='1' else 
		tgr_cid;

	vtgains_e : entity hdl4fpga.dpram
	port map (
		wr_clk  => rgtr_clk,
		wr_ena  => vtscale_ena,
		wr_addr => vt_scalecid,
		wr_data => vt_scaleid,
		rd_addr => vt_cid,
		rd_data => tbl_scaleid);

	process (rgtr_clk)
	begin
		if rising_edge(rgtr_clk) then
			if (mark_req xor mark_rdy)='0' then
				if vtscale_ena='1' then
					export_vtoffset <= tbl_offset;
				elsif vtoffset_ena='1' then
					export_vtoffset <= vt_offset;
				end if;
			end if;
		end if;
	end process;

end;
