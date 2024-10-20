
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.scopeiopkg.all;

entity scopeio_state is
	port (
		rgtr_clk        : in  std_logic;
		rgtr_dv         : in  std_logic;
		rgtr_id         : in  std_logic_vector;
		rgtr_data       : in  std_logic_vector;

		hz_ena          : buffer std_logic;
		hz_scaleid      : out std_logic_vector;
		hz_offset       : out std_logic_vector;
		chan_id         : in  std_logic_vector;
		vtscale_ena     : buffer std_logic;
		vt_scalecid     : out std_logic_vector;
		vt_scaleid      : out std_logic_vector(4-1 downto 0);
		vtoffset_ena    : buffer std_logic;
		vt_offsetcid    : out std_logic_vector;
		vt_offset       : out std_logic_vector;

		trigger_ena     : buffer std_logic;
		trigger_chanid  : out std_logic_vector;
		trigger_slope   : out std_logic;
		trigger_oneshot : out std_logic;
		trigger_freeze  : out std_logic;
		trigger_level   : out std_logic_vector);
end;

architecture def of scopeio_state is

	signal rqtd_vtscalecid  : std_logic_vector(chan_id'range);
	signal rqtd_vtscaleid   : std_logic_vector(vt_scaleid'range);
	signal tbl_vtscaleid    : std_logic_vector(vt_scaleid'range);

	signal rqtd_vtoffsetcid : std_logic_vector(chan_id'range);
	signal rqtd_vtoffset    : std_logic_vector(vt_offset'range);
	signal tbl_vtoffset     : std_logic_vector(vt_offset'range);

	signal rqtd_tgrfreeze   : std_logic;
	signal rqtd_tgrslope    : std_logic;
	signal rqtd_tgroneshot  : std_logic;
	signal rqtd_tgrcid      : std_logic_vector(chan_id'range);
	signal rqtd_tgrlevel    : std_logic_vector(trigger_level'range);

	signal tgr_slope        : std_logic;
	signal tgr_oneshot      : std_logic;
	signal tgr_freeze       : std_logic;

	signal rqtd_hzscaleid   : std_logic_vector(4-1 downto 0);
	signal rqtd_hzoffset    : std_logic_vector(hz_offset'range);

	signal rqtd_tgrdata    : std_logic_vector((trigger_level'length+3)-1 downto 0);
	signal tbl_tgrdata     : std_logic_vector(rqtd_tgrdata'range);

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

	process (hz_ena, rqtd_hzscaleid, rqtd_hzoffset, rgtr_clk)
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
	vt_scalecid <= rqtd_vtscalecid;

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
	vt_offsetcid <= rqtd_vtoffsetcid;

	vtoffsets_e : entity hdl4fpga.dpram
	port map (
		wr_clk  => rgtr_clk,
		wr_ena  => vtoffset_ena,
		wr_addr => rqtd_vtoffsetcid,
		wr_data => rqtd_vtoffset,
		rd_addr => chan_id,
		rd_data => tbl_vtoffset);

	vtscales_e : entity hdl4fpga.dpram
	port map (
		wr_clk  => rgtr_clk,
		wr_ena  => vtscale_ena,
		wr_addr => rqtd_vtscalecid,
		wr_data => rqtd_vtscaleid,
		rd_addr => chan_id,
		rd_data => tbl_vtscaleid);

	vt_scaleid <= 
		tbl_vtscaleid  when vtscale_ena='0' else
		rqtd_vtscaleid when rqtd_vtscalecid=chan_id else
		tbl_vtscaleid;

	vt_offset <= 
		tbl_vtoffset  when vtoffset_ena='0' else
		rqtd_vtoffset when rqtd_vtoffsetcid=chan_id else
		tbl_vtoffset;

	trigger_e : entity hdl4fpga.scopeio_rgtrtrigger
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

	process (rqtd_tgrcid, trigger_ena, rgtr_clk)
		variable cid : std_logic_vector(chan_id'range);
	begin
		if rising_edge(rgtr_clk) then
			if trigger_ena='1' then
				cid := rqtd_tgrcid;
			end if;
		end if;
		if trigger_ena='1' then
			trigger_chanid <= rqtd_tgrcid;
		else
			trigger_chanid <= cid;
		end if;
	end process;

	rqtd_tgrdata <= rqtd_tgrlevel & rqtd_tgrslope & rqtd_tgroneshot & rqtd_tgrfreeze;
	triggers_e : entity hdl4fpga.dpram
	port map (
		wr_clk  => rgtr_clk,
		wr_ena  => trigger_ena,
		wr_addr => rqtd_tgrcid,
		wr_data => rqtd_tgrdata,
		rd_addr => chan_id,
		rd_data => tbl_tgrdata);

	process (trigger_ena, rqtd_tgrslope, rqtd_tgroneshot, rqtd_tgrfreeze, rqtd_tgrlevel, tbl_tgrdata)
		variable tgrdata : unsigned(tbl_tgrdata'range);
	begin
		if trigger_ena='1' then
			trigger_level   <= rqtd_tgrlevel;
			trigger_slope   <= rqtd_tgrslope;
			trigger_oneshot <= rqtd_tgroneshot;
			trigger_freeze  <= rqtd_tgrfreeze;
		else
			tgrdata := unsigned(tbl_tgrdata);
			tgrdata := tgrdata rol trigger_level'length;
			trigger_level <= std_logic_vector(tgrdata(trigger_level'length-1 downto 0));
			tgrdata := tgrdata rol 1;
			trigger_slope <= tgrdata(0);
			tgrdata := tgrdata rol 1;
			trigger_oneshot <= tgrdata(0);
			tgrdata := tgrdata rol 1;
			trigger_freeze <= tgrdata(0);
		end if;
	end process;
end;
