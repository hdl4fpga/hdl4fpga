
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
		tp      : out std_logic_vector(1 to 32);
		req     : in  std_logic;
		rdy     : buffer std_logic;
		event   : in  std_logic_vector(0 to 2-1);
		video_vton : in std_logic;

		sio_clk : in  std_logic;
		si_frm  : in  std_logic := '0';
		si_irdy : in  std_logic := '1';
		si_trdy : out std_logic := '0';
		si_data : in  std_logic_vector;
		so_frm  : buffer std_logic;
		so_irdy : buffer std_logic;
		so_trdy : in  std_logic := '1';
		so_data : buffer std_logic_vector := (0 to 7 => '-'));

	constant inputs        : natural := hdo(layout)**".inputs";
	constant max_delay     : natural := hdo(layout)**".max_delay=16384.";
	constant hz_unit       : real    := hdo(layout)**".axis.horizontal.unit";
	constant vt_unit       : real    := hdo(layout)**".axis.vertical.unit";
	constant grid_height   : natural := hdo(layout)**".grid.height";

	constant hzoffset_bits : natural := unsigned_num_bits(max_delay-1);
	constant chanid_bits   : natural := unsigned_num_bits(inputs-1);

	constant event_enter : std_logic_vector := "00";
	constant event_exit  : std_logic_vector := "01";
	constant event_next  : std_logic_vector := "10";
	constant event_prev  : std_logic_vector := "11";
end;

architecture def of scopeio_ctlr is
	alias  rgtr_clk        is sio_clk;
	signal rgtr_id         : std_logic_vector(8-1 downto 0);
	signal rgtr_dv         : std_logic;
	signal rgtr_revs       : std_logic_vector(0 to 4*8-1);
	signal rgtr_data       : std_logic_vector(rgtr_revs'reverse_range);

    signal ctlr_frm  : std_logic;
    signal ctlr_irdy : std_logic;
    signal ctlr_trdy : std_logic := '1';
    signal ctlr_data : std_logic_vector(si_data'range);

	signal hz_scaleid      : std_logic_vector(4-1 downto 0);
	signal hz_offset       : std_logic_vector(hzoffset_bits-1 downto 0);
	signal chan_id         : unsigned(chanid_bits-1 downto 0);
	signal vtscale_ena     : std_logic;
	signal vt_scalecid     : std_logic_vector(chan_id'range);
	signal vt_scaleid      : std_logic_vector(4-1 downto 0);
	signal vtoffset_ena    : std_logic;
	signal vt_offsetcid    : std_logic_vector(chan_id'range);
	signal vt_offset       : std_logic_vector((5+8)-1 downto 0);

	signal trigger_ena     : std_logic;
	signal trigger_chanid  : std_logic_vector(chan_id'range);
	signal trigger_slope   : std_logic_vector(0 to 1-1);
	signal trigger_mode    : std_logic_vector(0 to 2-1);
	alias  trigger_freeze  is trigger_mode(1);
	alias  trigger_oneshot is trigger_mode(0);
	signal trigger_level   : std_logic_vector(unsigned_num_bits(grid_height)-1 downto 0);
	
	constant tab : natural_vector(0 to wid_inscale) := (
		wid_tmposition => to_integer(unsigned(rid_hzaxis)),
		wid_tmscale    => to_integer(unsigned(rid_hzaxis)),
		wid_tgchannel  => to_integer(unsigned(rid_trigger)),
		wid_tgposition => to_integer(unsigned(rid_trigger)),
		wid_tgslope    => to_integer(unsigned(rid_trigger)),
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
			"wid_tgslope,"     &
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
			wid_tgposition => wid_tgslope,    
			wid_tgslope    => wid_tgmode,    
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
			wid_trigger    => wid_tgchannel,
			wid_tmposition => wid_tmposition,   
			wid_tmscale    => wid_tmscale, 
			wid_tgchannel  => wid_tgchannel,
			wid_tgposition => wid_tgposition,    
			wid_tgslope    => wid_tgslope,    
			wid_tgmode     => wid_tgmode,
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

	function up_sequence
		return natural_vector is
		variable retval : natural_vector(0 to wid_inscale+3*(inputs-1)) := (
			wid_time       => wid_time,
			wid_trigger    => wid_trigger,
			wid_tmposition => wid_time,   
			wid_tmscale    => wid_time, 
			wid_tgchannel  => wid_trigger,
			wid_tgposition => wid_trigger,    
			wid_tgslope    => wid_trigger,    
			wid_tgmode     => wid_trigger,
			wid_input      => wid_input,
			wid_inposition => wid_input,
			wid_inscale    => wid_input,
			others         => 0);
	begin
		for i in wid_input+3 to wid_inscale+3*(inputs-1) loop
			retval(i) := retval(i-3) + 3;
		end loop;
		return retval;
	end;

	constant next_tab   : natural_vector := next_sequence;
	constant prev_tab   : natural_vector := prev_sequence(next_tab);
	constant enter_tab  : natural_vector := enter_sequence;
	constant escape_tab : natural_vector := up_sequence;

	signal focus_req   : std_logic := '0';
	signal focus_rdy   : std_logic := '0';
	signal change_rdy  : std_logic;
	signal change_req  : std_logic;
	signal ctrl_rgtr   : unsigned(0 to 5*8-1);
	alias  rid         : unsigned(0 to 1*8-1) is ctrl_rgtr(0*8 to 1*8-1);
	alias  reg_length  : unsigned(0 to 1*8-1) is ctrl_rgtr(1*8 to 2*8-1);
	alias  payload     : unsigned(0 to 3*8-1) is ctrl_rgtr(2*8 to 5*8-1); 
	signal send_req    : std_logic := '0';
	signal send_rdy    : std_logic := '0';
	signal timer_req   : std_logic := '0';
	signal timer_rdy   : std_logic := '0';
	signal send_data   : std_logic_vector(so_data'range);
	constant timeout0 : natural range 0 to 59 := 30;
	constant timeout1 : natural range 0 to 59 := 1;

	function input_length (
		constant arg : std_logic_vector(0 to 4-1))
		return natural is
	begin
		case arg is
		when x"0" =>
			return 1;
		when x"1" => 
			return 2;
		when x"2" => 
			return 4;
		when x"3" => 
			return 5;
		when others =>
			return inputs;
		end case;
	end;

	function upto (
		constant arg : std_logic_vector(0 to 4-1))
		return natural is
	begin
		return wid_input+input_length(arg)*3-1;
	end;
begin

	so_frm  <= si_frm  when si_frm='1' else ctlr_frm;
	so_irdy <= si_irdy when si_frm='1' else ctlr_irdy;
	si_trdy <= so_trdy when ctlr_frm='0' else ctlr_trdy;
	so_data <= si_data when si_frm='1' else ctlr_data;

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
		chan_id         => std_logic_vector(chan_id),
		vtscale_ena     => vtscale_ena,
		vt_scalecid     => vt_scalecid,
		vt_scaleid      => vt_scaleid,
		vtoffset_ena    => vtoffset_ena,
		vt_offsetcid    => vt_offsetcid,
		vt_offset       => vt_offset,
				  
		trigger_ena     => trigger_ena,
		trigger_chanid  => trigger_chanid,
		trigger_slope   => trigger_slope(0),
		trigger_oneshot => trigger_oneshot,
		trigger_freeze  => trigger_freeze,
		trigger_level   => trigger_level);

	tp(1 to 4) <= (send_req, send_rdy, req, rdy);
	process (req, rgtr_clk)
		type states is (s_navigate, s_hightlight, s_selected, s_tgchannel, s_hightlight2);
		variable state     : states;
		variable values    : integer_vector(0 to wid_inscale);
		variable value     : natural range values'range;
		variable focus_wid : natural range next_tab'range;
		variable blink     : natural range 0 to 2**7;
	begin
		if rising_edge(rgtr_clk) then
			if (rdy xor req)='1' and (timer_req xor timer_rdy)='0' then
				if (send_req xor send_rdy)='0' then
					case state is
					when s_navigate =>

						case event is
						when event_enter =>
							if focus_wid=enter_tab(focus_wid) then
								blink := 2**7;
								state := s_selected;
							end if;
							focus_wid := enter_tab(focus_wid);
							(send_req, timer_req) <= std_logic_vector'(not send_rdy, not timer_rdy);
						when event_next =>
							blink := 0;
							focus_wid := next_tab(focus_wid);
							if focus_wid > upto(hz_scaleid) then
								if ((focus_wid-wid_input) mod 3)=0 then
									focus_wid := wid_time;
								else
									focus_wid := wid_tmposition;
								end if;
							end if;
							send_req <= not send_rdy;
							state := s_hightlight;
						when event_prev =>
							blink := 0;
							focus_wid := prev_tab(focus_wid);
							if focus_wid > upto(hz_scaleid) then
								if ((focus_wid-wid_input) mod 3)=0 then
									focus_wid := upto(hz_scaleid)-2;
								else
									focus_wid := upto(hz_scaleid);
								end if;
							end if;
							send_req <= not send_rdy;
							state := s_hightlight;
						when event_exit =>
							focus_wid := escape_tab(focus_wid);
							blink := 0;
							(send_req, timer_req) <= std_logic_vector'(not send_rdy, not timer_rdy);
						when others =>
							assert false
								report "scopeio_ctlr : invalid event"
								severity FAILURE;
						end case;

						case focus_wid is
						when wid_input|wid_trigger|wid_tmposition|wid_tmscale|wid_tgchannel|wid_tgposition|wid_tgslope|wid_tgmode =>
							value := focus_wid;
							chan_id <= unsigned(trigger_chanid);
						when others =>
							for i in wid_input to next_tab'right loop
								if focus_wid=i then
									chan_id <= to_unsigned((i-wid_input)/3, chan_id'length);
									case (i-wid_input) mod 3 is
									when 0 => 
									when 1 => 
										value := wid_inposition;
									when 2 => 
										value := wid_inscale;
									when others =>
										assert false
										report "scopeio_ctlr : invalid event"
										severity FAILURE;
									end case;
									exit;
								end if;
							end loop;
						end case;

						rid <= unsigned(rid_focus);
						reg_length <= x"00";
						payload (0 to 8-1) <= to_unsigned(focus_wid+blink, 8);
					when s_selected =>
						values := (
							wid_tmposition => to_integer(signed(hz_offset)),
							wid_tmscale    => to_integer(unsigned(hz_scaleid)),
							wid_tgchannel  => to_integer(unsigned(trigger_chanid)),
							wid_tgposition => to_integer(signed(trigger_level)),
							wid_tgslope    => to_integer(unsigned(trigger_slope)),
							wid_tgmode     => to_integer(unsigned(trigger_mode)),
							wid_inposition => to_integer(signed(vt_offset)),
							wid_inscale    => to_integer(unsigned(vt_scaleid)),
							others         => 0);

						case event is
						when event_next|event_prev =>
							if event=event_next then
								values(value) := values(value) - 1;
							else
								values(value) := values(value) + 1;
							end if;

    						values := (
    							wid_tmposition => values(wid_tmposition) rem 2**(hz_offset'length-1),
    							wid_tmscale    => values(wid_tmscale)    mod 2**hz_scaleid'length,
    							wid_tgchannel  => values(wid_tgchannel)  mod 2**trigger_chanid'length,
    							wid_tgposition => values(wid_tgposition) rem 2**(trigger_level'length-1),
    							wid_tgslope    => values(wid_tgslope)    mod 2**trigger_slope'length,
    							wid_tgmode     => values(wid_tgmode)     mod 2**trigger_mode'length,
    							wid_inposition => values(wid_inposition) rem 2**(vt_offset'length-1),
    							wid_inscale    => values(wid_inscale)    mod 2**vt_scaleid'length,
    							others => 0);

    						case value is
    						when wid_tmposition|wid_tmscale =>
    							rid <= unsigned(rid_hzaxis);
    							reg_length <= x"02";
    							payload <= resize(
    								to_unsigned(values(wid_tmscale), hzscale_maxsize) & 
    								unsigned(to_signed(values(wid_tmposition), hzoffset_maxsize)), 3*8);
								(send_req, timer_req) <= std_logic_vector'(not send_rdy, not timer_rdy);
    						when wid_tgchannel =>
								if not (values(value) < input_length(hz_scaleid)) then 
									values(value) := 0;
								end if;
    							chan_id <= to_unsigned(values(value), chan_id'length);
    							state := s_tgchannel;
    						when wid_tgposition|wid_tgslope|wid_tgmode =>
    							rid <= unsigned(rid_trigger);
    							reg_length <= x"02";
    							payload <= resize(
    								to_unsigned(values(wid_tgchannel), chanid_maxsize) &
    								unsigned(to_signed(values(wid_tgposition), triggerlevel_maxsize)) & 
    								to_unsigned(values(wid_tgslope), trigger_slope'length)  & 
    								to_unsigned(values(wid_tgmode),  trigger_mode'length), 3*8);
								(send_req, timer_req) <= std_logic_vector'(not send_rdy, not timer_rdy);
    						when wid_inposition =>
    							rid <= unsigned(rid_vtaxis);
    							reg_length <= x"02";
    							payload <= resize(
    								resize(chan_id, chanid_maxsize) &
    								unsigned(to_signed(values(wid_inposition), vtoffset_maxsize)), 3*8);
								(send_req, timer_req) <= std_logic_vector'(not send_rdy, not timer_rdy);
    						when wid_inscale =>
    							rid <= unsigned(rid_gain);
    							reg_length <= x"01";
    							payload(0 to 2*8-1) <= resize(
    								resize(chan_id, chanid_maxsize) &
    								to_unsigned(values(wid_inscale), vt_scaleid'length), 2*8);
								(send_req, timer_req) <= std_logic_vector'(not send_rdy, not timer_rdy);
    						when others =>
								assert false
									report "scopeio_ctlr : invalid value"
									severity FAILURE;
    						end case;
						when event_exit |event_enter =>
							rid <= unsigned(rid_focus);
							reg_length <= x"00";
							payload (0 to 8-1) <= to_unsigned(focus_wid, 8);
							(send_req, timer_req) <= std_logic_vector'(not send_rdy, not timer_rdy);
							state := s_navigate;
						when others =>
							assert false
								report "scopeio_ctlr : invalid event"
								severity FAILURE;
						end case;
					when s_hightlight =>
						rid <= unsigned(rid_gain);
						reg_length <= x"01";
						payload(0 to 2*8-1) <= resize(
							resize(chan_id, chanid_maxsize) &
							resize(unsigned(vt_scaleid), vt_scaleid'length), 2*8);
						(send_req, timer_req) <= std_logic_vector'(not send_rdy, not timer_rdy);
						state := s_navigate;
					when s_tgchannel =>
						rid <= unsigned(rid_trigger);
						reg_length <= x"02";
						payload <= resize(
							resize(chan_id, chanid_maxsize) &
							unsigned(resize(signed(trigger_level), triggerlevel_maxsize)) & 
							resize(unsigned(trigger_slope), trigger_slope'length)  & 
							resize(unsigned(trigger_mode),  trigger_mode'length), 3*8);
						send_req <= not send_rdy;
						state := s_hightlight2;
					when s_hightlight2 =>
						rid <= unsigned(rid_gain);
						reg_length <= x"01";
						payload(0 to 2*8-1) <= resize(
							resize(chan_id, chanid_maxsize) &
							resize(unsigned(vt_scaleid), vt_scaleid'length), 2*8);
						(send_req, timer_req) <= std_logic_vector'(not send_rdy, not timer_rdy);
						state := s_selected;
					end case;
				end if;
			end if;

			tp(5 to 8) <= std_logic_vector(to_unsigned(states'pos(state), 4));
		end if;
	end process;
	
	process (rgtr_clk)
		type states is (s_init, s_length, s_data);
		variable state : states;
		variable rgtr : unsigned(ctrl_rgtr'range);
		variable cntr : integer range -1 to 2**reg_length'length-1;
	begin
		if rising_edge(rgtr_clk) then
			if (send_req xor send_rdy)='1' then
				case state is
				when s_init =>
					rgtr      := ctrl_rgtr;
					ctlr_frm    <= '1';
					ctlr_irdy   <= '1';
					send_data <= std_logic_vector(rgtr(send_data'range));
					rgtr      := shift_left(rgtr, rid'length);
					state := s_length;
				when s_length =>
					cntr      := to_integer(rgtr(send_data'range));
					ctlr_frm    <= '1';
					ctlr_irdy   <= '1';
					send_data <= std_logic_vector(rgtr(send_data'range));
					rgtr      := shift_left(rgtr, rid'length);
					state := s_data;
				when s_data =>
					if cntr >= 0 then
						ctlr_frm    <= '1';
						ctlr_irdy   <= '1';
						send_data <= std_logic_vector(rgtr(send_data'range));
						rgtr      := shift_left(rgtr, rid'length);
						cntr := cntr -1;
					else
						ctlr_frm    <= '0';
						ctlr_irdy   <= '0';
						send_data <= std_logic_vector(rgtr(send_data'range));
						rgtr      := shift_left(rgtr, rid'length);
						send_rdy  <= send_req;
						state    := s_init;
					end if;
				end case;
			else
				ctlr_frm    <= '0';
				ctlr_irdy   <= '0';
				send_data <= std_logic_vector(rgtr(send_data'range));
			end if;
		end if;
	end process;
	ctlr_data <= reverse(send_data);
	
	process (sio_clk)
		variable cntr : integer range -1 to 59;
		variable edge : std_logic;
	begin
		if rising_edge(rgtr_clk) then
			if (not video_vton and edge)='1' then
    			if (timer_rdy xor timer_req)='1' then
    				if cntr < 0 then
						timer_rdy <= timer_req;
						if (rdy xor req)='1' then
							cntr := timeout1;
						else
							cntr := timeout0;
						end if;
    				else
    					cntr := cntr - 1;
						rdy  <= req;
    				end if;
    			else
    				cntr := timeout0;
				end if;
			end if;
			edge := video_vton;
		end if;
	end process;
end;