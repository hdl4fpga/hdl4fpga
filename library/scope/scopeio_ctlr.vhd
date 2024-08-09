
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.hdo.all;
use hdl4fpga.scopeiopkg.all;

entity scopeio_ctlr is
	generic (
		layout  : string);
	port (
		req     : in  std_logic;
		rdy     : buffer std_logic;
		event   : in  std_logic_vector;

		sio_clk : in  std_logic;
		so_frm  : buffer std_logic;
		so_irdy : buffer std_logic;
		so_trdy : in  std_logic := '0';
		so_data : buffer std_logic_vector := (0 to 7 => '-'));

	constant inputs        : natural := hdo(layout)**".inputs";
	constant max_delay     : natural := hdo(layout)**".max_delay=16384.";
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
	
	constant tab : natural_vector(0 to wid_inscale) := (
		wid_tmposition => to_integer(unsigned(rid_hzaxis)),
		wid_tmscale    => to_integer(unsigned(rid_hzaxis)),
		wid_tgchannel  => to_integer(unsigned(rid_trigger)),
		wid_tgposition => to_integer(unsigned(rid_trigger)),
		wid_tgedge     => to_integer(unsigned(rid_trigger)),
		wid_tgmode     => to_integer(unsigned(rid_trigger)),
		wid_inposition => to_integer(unsigned(rid_vtaxis)),
		wid_inscale    => to_integer(unsigned(rid_gain)),
		others         => 0);

	constant images : string := compact(
		"[" &
			"wid_time,"       &
			"wid_trigger,"    &
			"wid_tmposition," &
			"wid_tmscale,"    &
			"wid_tgchannel,"  &
			"wid_tgposition," &
			"wid_tgedge,"     &
			"wid_tgmode,"     &
			"wid_input,"      &
			"wid_inposition," &
			"wid_inscale"     &
		"]");

	function next_sequence 
		return natural_vector is
		variable retval : natural_vector(0 to wid_inscale+3*(inputs-1)) := (
			wid_time       => wid_trigger,
			wid_trigger    => wid_input,
			wid_tmposition => wid_tmscale,   
			wid_tmscale    => wid_tgchannel, 
			wid_tgchannel  => wid_tgposition,
			wid_tgposition => wid_tgedge,    
			wid_tgedge     => wid_tgmode,    
			wid_tgmode     => wid_inposition,
			wid_input      => wid_time,
			wid_inposition => wid_inscale,
			wid_inscale    => wid_tmposition,
			others         => 0);
	begin
		retval(3*(inputs-1)+wid_input) := retval(wid_input);
		retval(wid_input) := wid_input+3;
		retval(3*(inputs-1)+wid_inscale) := retval(wid_inscale);
		retval(wid_inscale) := wid_inposition+3;
		for i in wid_inscale+1 to wid_inscale+3*(inputs-2) loop
			retval(i) := retval(i-3) + 3;
		end loop;
		retval(3*(inputs-1)+wid_inposition) := 3*(inputs-1)+wid_inscale;
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
		variable retval : natural_vector(0 to wid_inscale+3*(inputs-1)) := (
			wid_time       => wid_tmposition,
			wid_trigger    => wid_tgposition,
			wid_tmposition => wid_tmposition,   
			wid_tmscale    => wid_tmscale, 
			wid_tgchannel  => wid_tgchannel,
			wid_tgposition => wid_tgposition,    
			wid_tgedge     => wid_tgedge,    
			wid_tgmode     => wid_tgedge,
			wid_input      => wid_inposition,
			wid_inposition => wid_inposition,
			wid_inscale    => wid_inscale,
			others         => 0);
	begin
		for i in wid_input+3 to wid_inscale+3*(inputs-1) loop
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

	signal focus_req   : std_logic := '0';
	signal focus_rdy   : std_logic := '0';
	signal focus_wid   : natural range 0 to next_tab'length-1;
	signal change_rdy  : std_logic;
	signal change_req  : std_logic;
	signal send_req    : bit := '0';
	signal send_rdy    : bit := '0';
	signal send_data   : std_logic_vector(so_data'range);

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

	process (req, rgtr_clk)
		type states is (s_idle, s_send);
		variable state : states;
	begin
		if rising_edge(rgtr_clk) then
			case state is
			when s_idle =>
				if (send_req xor send_rdy)='0' then
					if (to_bit(rdy) xor to_bit(req))='1' then
						if event="00" then
							focus_wid <= (focus_wid + 1) mod next_tab'length;
						else
							focus_wid <= (focus_wid - 1) mod next_tab'length;
						end if;
						send_req <= not send_rdy;
						state := s_send;
					end if;
				end if;
			when s_send =>
				if (send_req xor send_rdy)='0' then
					rdy <= to_stdulogic(to_bit(req));
					state := s_idle;
				end if;
			end case;
		end if;
	end process;
	
	process (rgtr_clk)
		type states is (s_init, s_length, s_data);
		variable state : states;
	begin
		if rising_edge(rgtr_clk) then
			if (send_req xor send_rdy)='1' then
				case state is
				when s_init =>
					so_frm  <= '1';
					so_irdy <= '1';
					send_data <= rid_focus;
					state := s_length;
				when s_length =>
					so_frm    <= '1';
					so_irdy   <= '1';
					send_data <= x"00";
					state := s_data;
				when s_data =>
					so_frm     <= '1';
					so_irdy    <= '1';
					send_data  <= std_logic_vector(to_unsigned(focus_wid, send_data'length));
					send_rdy   <= send_req;
					state := s_init;
				end case;
			else
				so_frm  <= '0';
				so_irdy <= '0';
				send_data <= (others => '-');
			end if;
		end if;
	end process;
	so_data <= reverse(send_data);
	
end;
