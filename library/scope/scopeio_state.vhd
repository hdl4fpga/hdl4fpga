
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.scopeiopkg.all;

entity scopeio_state is
	port (
		rgtr_clk   : in  std_logic;
		rgtr_dv    : in  std_logic;
		rgtr_id    : in  std_logic_vector;
		rgtr_data  : in  std_logic_vector;

		hz_scaleid : out std_logic_vector;
		hz_offset  : out std_logic_vector;
		vt_chanid  : out std_logic_vector;
		vt_scaleid : out std_logic_vector(4-1 downto 0);
		vt_offset  : out std_logic_vector;
		trigger_level : out std_logic_vector);

end;

architecture def of scopeio_state is

	signal vtscale_ena      : std_logic;
	signal rqtd_vtscalecid  : std_logic_vector(vt_chanid'range);
	signal rqtd_vtscaleid   : std_logic_vector(vt_chanid'range);
	signal tbl_vtscaleid    : std_logic_vector(vt_scaleid'range);
	signal vt_scalecid      : std_logic_vector(vt_chanid'range);

	signal vtoffset_ena     : std_logic;
	signal rqtd_vtoffsetcid : std_logic_vector(vt_chanid'range);
	signal rqtd_vtoffset    : std_logic_vector(vt_offset'range);
	signal tbl_vtoffset     : std_logic_vector(vt_offset'range);

	signal trigger_ena      : std_logic;
	signal rqtd_tgrfreeze   : std_logic;
	signal rqtd_tgrslope    : std_logic;
	signal rqtd_tgroneshot  : std_logic;
	signal rqtd_tgrcid      : std_logic_vector(vt_chanid'range);
	signal rqtd_tgrlevel    : std_logic_vector(trigger_level'range);

	signal hz_ena           : std_logic;
	signal rqtd_hzscaleid   : std_logic_vector(4-1 downto 0);
	signal rqtd_hzoffset    : std_logic_vector(hz_offset'range);

begin

	hzaxis_e : entity hdl4fpga.scopeio_rgtrhzaxis
	generic map (
		rgtr      => false)
	port map (
		rgtr_clk  => rgtr_clk,
		rgtr_dv   => rgtr_dv,
		rgtr_id   => rgtr_id,
		rgtr_data => rgtr_data,

		hz_ena    => hz_ena,
		hz_scale  => rqtd_hzscaleid,
		hz_offset => rqtd_hzoffset);

	process (hz_ena, rgtr_clk)
		variable scaleid : std_logic_vector(4-1 downto 0);
		variable offset  : std_logic_vector(hz_offset'range);
	begin
		if rising_edge(rgtr_clk) then
			if hz_ena='1' then
				scaleid := rqtd_hzscaleid;
				offset  := rqtd_hzoffset;
			end if;
		end if;
		if hz_ena='1' then
			hz_scaleid <= rqtd_hzscaleid;
			hz_offset  <= rqtd_hzoffset;
		else
			hz_scaleid <= scaleid;
			hz_offset  <= offset;
		end if;
	end process;

	vtscale_e : entity hdl4fpga.scopeio_rgtrvtscale
	generic map (
		rgtr      => false)
	port map (
		rgtr_clk  => rgtr_clk,
		rgtr_dv   => rgtr_dv,
		rgtr_id   => rgtr_id,
		rgtr_data => rgtr_data,

		vtscale_ena => vtscale_ena,
		vtchan_id   => rqtd_vtscalecid,
		vtscale_id  => rqtd_vtscaleid);

	vtoffset_e : entity hdl4fpga.scopeio_rgtrvtoffset
	generic map (
		rgtr      => false)
	port map (
		rgtr_clk  => rgtr_clk,
		rgtr_dv   => rgtr_dv,
		rgtr_id   => rgtr_id,
		rgtr_data => rgtr_data,

		vt_ena    => vtoffset_ena,
		vt_chanid => rqtd_vtoffsetcid,
		vt_offset => rqtd_vtoffset);

	triggers_e : entity hdl4fpga.scopeio_rgtrtrigger
	generic map (
		rgtr      => false)
	port map (
		rgtr_clk  => rgtr_clk,
		rgtr_dv   => rgtr_dv,
		rgtr_id   => rgtr_id,
		rgtr_data => rgtr_data,

		trigger_ena     => trigger_ena,
		trigger_chanid  => rqtd_tgrcid,
		trigger_slope   => rqtd_tgrslope,
		trigger_oneshot => rqtd_tgroneshot,
		trigger_freeze  => rqtd_tgrfreeze,
		trigger_level   => rqtd_tgrlevel);

	vtoffsets_e : entity hdl4fpga.dpram
	port map (
		wr_clk  => rgtr_clk,
		wr_ena  => vtoffset_ena,
		wr_addr => rqtd_vtoffsetcid,
		wr_data => rqtd_vtoffset,
		rd_addr => rqtd_vtscalecid,
		rd_data => tbl_vtoffset);

	vt_scalecid <= 
		rqtd_vtoffsetcid when vtoffset_ena='1' else 
		rqtd_tgrcid      when  trigger_ena='1';

	vtscales_e : entity hdl4fpga.dpram
	port map (
		wr_clk  => rgtr_clk,
		wr_ena  => vtscale_ena,
		wr_addr => vt_scalecid,
		wr_data => rqtd_vtscaleid,
		rd_addr => vt_scalecid,
		rd_data => tbl_vtscaleid);

	process (vtscale_ena, vtoffset_ena, rgtr_clk)
		variable scaleid : std_logic_vector(4-1 downto 0);
		variable offset  : std_logic_vector(hz_offset'range);
	begin
		if rising_edge(rgtr_clk) then
			if vtscale_ena='1' then
				offset := tbl_vtoffset;
			elsif vtoffset_ena='1' then
				offset := rqtd_vtoffset;
			end if;
		end if;
		if vtscale_ena='1' then
			vt_scaleid <= rqtd_vtscaleid;
		end if;
		if vtoffset_ena='1' then
			vt_offset <= rqtd_vtoffset;
		end if;
	end process;

end;
