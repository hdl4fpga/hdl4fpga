
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.hdo.all;
use hdl4fpga.scopeiopkg.all;

entity scopeio_ctlr is
	generic (
		layout    : string);
	port (
		exit_req  : in  std_logic;
		exit_rdy  : buffer std_logic;
		next_req  : in  std_logic;
		next_rdy  : buffer std_logic;
		prev_req  : in  std_logic;
		prev_rdy  : buffer std_logic;
		enter_req : in  std_logic;
		enter_rdy : buffer std_logic;

		sio_clk   : in  std_logic;
		so_frm    : buffer std_logic;
		so_irdy   : buffer std_logic;
		so_trdy   : in  std_logic := '0';
		so_data   : buffer std_logic_vector := (0 to 7 => '-'));

	constant inputs        : natural := hdo(layout)**".inputs";
	constant max_delay     : natural := hdo(layout)**".max_delay";
	constant hz_unit       : real    := hdo(layout)**".axis.horizontal.unit";
	constant vt_unit       : real    := hdo(layout)**".axis.vertical.unit";
	constant grid_height   : natural := hdo(layout)**".grid.height";

	constant hzoffset_bits : natural := unsigned_num_bits(max_delay-1);
	constant chanid_bits   : natural := unsigned_num_bits(inputs-1);

end;

architecture def of scopeio_ctlr is
	alias  rgtr_clk        is sio_clk;
	signal rgtr_id         : std_logic_vector(8-1 downto 0);
	signal rgtr_dv         : std_logic;
	signal rgtr_revs       : std_logic_vector(0 to 4*8-1);
	signal rgtr_data       : std_logic_vector(rgtr_revs'reverse_range);

	signal hz_scaleid      : std_logic_vector(4-1 downto 0);
	signal hz_offset       : std_logic_vector(hzoffset_bits-1 downto 0);
	signal chan_id         : std_logic_vector(chanid_bits-1 downto 0);
	signal vtscale_ena     : std_logic;
	signal vt_scalecid     : std_logic_vector(chan_id'range);
	signal vt_scaleid      : std_logic_vector(4-1 downto 0);
	signal vtoffset_ena    : std_logic;
	signal vt_offsetcid    : std_logic_vector(chan_id'range);
	signal vt_offset       : std_logic_vector((5+8)-1 downto 0);

	signal trigger_ena     : std_logic;
	signal trigger_chanid  : std_logic_vector(chan_id'range);
	signal trigger_slope   : std_logic;
	signal trigger_oneshot : std_logic;
	signal trigger_freeze  : std_logic;
	signal trigger_level   : std_logic_vector(unsigned_num_bits(grid_height)-1 downto 0);
	
	constant key_time       : natural := 0;
	constant key_trigger    : natural := 1;
	constant key_tmposition : natural := 2;
	constant key_tmscale    : natural := 3;
	constant key_tgchannel  : natural := 4;
	constant key_tgposition : natural := 5;
	constant key_tgedge     : natural := 6;
	constant key_tgmode     : natural := 7;
	constant key_input      : natural := 8;
	constant key_inposition : natural := 9;
	constant key_inscale    : natural := 10;

	constant tab : natural_vector(0 to key_inscale) := (
		key_tmposition => to_integer(unsigned(rid_hzaxis)),
		key_tmscale    => to_integer(unsigned(rid_hzaxis)),
		key_tgchannel  => to_integer(unsigned(rid_trigger)),
		key_tgposition => to_integer(unsigned(rid_trigger)),
		key_tgedge     => to_integer(unsigned(rid_trigger)),
		key_tgmode     => to_integer(unsigned(rid_trigger)),
		key_inposition => to_integer(unsigned(rid_vtaxis)),
		key_inscale    => to_integer(unsigned(rid_gain)),
		others         => 0);

	constant images : string := compact(
		"[" &
			"key_time,"       &
			"key_trigger,"    &
			"key_tmposition," &
			"key_tmscale,"    &
			"key_tgchannel,"  &
			"key_tgposition," &
			"key_tgedge,"     &
			"key_tgmode,"     &
			"key_input,"      &
			"key_inposition," &
			"key_inscale"     &
		"]");

	function next_sequence 
		return natural_vector is
		variable retval : natural_vector(0 to key_inscale+3*(inputs-1)) := (
			key_time       => key_trigger,
			key_trigger    => key_input,
			key_tmposition => key_tmscale,   
			key_tmscale    => key_tgchannel, 
			key_tgchannel  => key_tgposition,
			key_tgposition => key_tgedge,    
			key_tgedge     => key_tgmode,    
			key_tgmode     => key_inposition,
			key_input      => key_time,
			key_inposition => key_inscale,
			key_inscale    => key_tmposition,
			others         => 0);
	begin
		retval(3*(inputs-1)+key_input) := retval(key_input);
		retval(key_input) := key_input+3;
		retval(3*(inputs-1)+key_inscale) := retval(key_inscale);
		retval(key_inscale) := key_inposition+3;
		for i in key_inscale+1 to key_inscale+3*(inputs-2) loop
			retval(i) := retval(i-3) + 3;
		end loop;
		retval(3*(inputs-1)+key_inposition) := 3*(inputs-1)+key_inscale;
		return retval;
	end;

	function prev_sequence (
		constant arg : natural_vector)
		return natural_vector is
		variable retval : natural_vector(arg'range);
	begin
		for i in arg'range loop
			retval(arg(i)) := i;
		end loop;
		return retval;
	end;

	function enter_sequence 
		return natural_vector is
		variable retval : natural_vector(0 to key_inscale+3*(inputs-1)) := (
			key_time       => key_tmposition,
			key_trigger    => key_tgposition,
			key_tmposition => key_tmposition,   
			key_tmscale    => key_tmscale, 
			key_tgchannel  => key_tgchannel,
			key_tgposition => key_tgposition,    
			key_tgedge     => key_tgedge,    
			key_tgmode     => key_tgedge,
			key_input      => key_inposition,
			key_inposition => key_inposition,
			key_inscale    => key_inscale,
			others         => 0);
	begin
		for i in key_input+3 to key_inscale+3*(inputs-1) loop
			retval(i) := retval(i-3) + 3;
		end loop;
		return retval;
	end;

	function exit_sequence (
		constant arg : natural_vector)
		return natural_vector is
		variable retval : natural_vector(arg'range);
	begin
		for i in arg'range loop
			if arg(i)/=i then
				retval(arg(i)) := i;
			else
				retval(i) := i;
			end if;
		end loop;
		return retval;
	end;

	constant next_tab  : natural_vector := next_sequence;
	constant prev_tab  : natural_vector := prev_sequence(next_tab);
	constant enter_tab : natural_vector := enter_sequence;
	constant exit_tab  : natural_vector := exit_sequence(enter_tab);

	signal focus_rdy   : std_logic;
	signal focus_req   : std_logic;
	signal focus       : natural range 0 to next_tab'length-1;
	signal change_rdy  : std_logic;
	signal change_req  : std_logic;
	signal send_rdy    : std_logic;
	signal send_req    : std_logic;
	signal send_data   : std_logic_vector(0 to 8-1);

begin

	siosin_e : entity hdl4fpga.sio_sin
	port map (
		sin_clk   => sio_clk,
		sin_frm   => so_frm,
		sin_irdy  => so_trdy,
		sin_data  => so_data,
		rgtr_id   => rgtr_id,
		rgtr_dv   => rgtr_dv,
		rgtr_data => rgtr_revs);
	rgtr_data <= reverse(rgtr_revs,8);

	state_e : entity hdl4fpga.scopeio_state
	port map (
		rgtr_clk        => rgtr_clk,
		rgtr_dv         => rgtr_dv,
		rgtr_id         => rgtr_id,
		rgtr_data       => rgtr_data,

		hz_scaleid      => hz_scaleid,
		hz_offset       => hz_offset,
		chan_id         => chan_id,
		vtscale_ena     => vtscale_ena,
		vt_scalecid     => vt_scalecid,
		vt_scaleid      => vt_scaleid,
		vtoffset_ena    => vtoffset_ena,
		vt_offsetcid    => vt_offsetcid,
		vt_offset       => vt_offset,
				  
		trigger_ena     => trigger_ena,
		trigger_chanid  => trigger_chanid,
		trigger_slope   => trigger_slope,
		trigger_oneshot => trigger_oneshot,
		trigger_freeze  => trigger_freeze,
		trigger_level   => trigger_level);

	process (rgtr_clk)
		type states is (s_idle, s_focus, s_change);
		variable state : states;
	begin
		if rising_edge(rgtr_clk) then
			case state is
			when s_idle =>
				if (focus_req xor focus_rdy)='0' then
					if (next_rdy xor next_req)='1' then
						focus <= next_tab(focus);
						if focus=next_tab(focus) then
							change_req <= not change_rdy;
							state := s_change;
						else
							focus_req <= not focus_rdy;
							state := s_focus;
						end if;
					elsif (prev_rdy xor prev_req)='1' then
						if focus=prev_tab(focus) then
							change_req <= not change_rdy;
							state := s_change;
						else
							focus_req <= not focus_rdy;
							state := s_focus;
						end if;
						focus <= prev_tab(focus);
						focus_req <= not focus_rdy;
						state := s_focus;
					elsif (enter_rdy xor enter_req)='1' then
						focus <= enter_tab(focus);
						focus_req <= not focus_rdy;
						state := s_focus;
					elsif (exit_rdy xor exit_req)='1' then
						focus <= exit_tab(focus);
						focus_req <= not focus_rdy;
						state := s_focus;
					end if;
				end if;
			when s_focus =>
				if (focus_req xor focus_rdy)='0' then
				end if;
			when s_change =>
			end case;
		end if;
	end process;
	
	process (rgtr_clk)
	begin
		if rising_edge(rgtr_clk) then
			if (focus_req xor focus_rdy)='1' then
			end if;
		end if;
	end process;
	
	process (rgtr_clk)
		type states is (s_init, s_send);
		variable state : states;
	begin
		if rising_edge(rgtr_clk) then
			if (send_req xor send_rdy)='1' then
				case state is
				when s_init =>
					if (focus_rdy xor focus_req)='1' then
						send_data <= rid_focus;
						state := s_send;
					elsif (change_rdy xor change_req)='1' then
						case focus is
						-- send_data <= rid_xxx;
						when others =>
						end case;
					end if;
				when s_send =>
				end case;
			end if;
		end if;
	end process;
	
end;
