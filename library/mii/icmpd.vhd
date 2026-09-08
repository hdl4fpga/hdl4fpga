-- Copyright (c) 2015 Miguel Angel Sagreras                                       --
--                                                                                --
-- Permission is hereby granted, free of charge, to any person obtaining a copy   --
-- of this software and associated documentation files (the "Software"), to deal  --
-- in the Software without restriction, including without limitation the rights   --
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      --
-- copies of the Software, and to permit persons to whom the Software is          --
-- furnished to do so, subject to the following conditions:                       --
--                                                                                --
-- The above copyright notice and this permission notice shall be included in all --
-- copies or substantial portions of the Software.                                --
--                                                                                --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  --
-- SOFTWARE.                                                                      --
--                                                                                --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.hdo.all;
use hdl4fpga.base.all;
use hdl4fpga.ipoepkg.all;

entity icmpd is
	port (
		miirx_clk   : in  std_logic;

		sharx_frm   : in  std_logic;
		sharx_irdy  : in  std_logic;
		sharx_trdy  : buffer std_logic := '1';

		sparx_frm   : in  std_logic;
		sparx_irdy  : in  std_logic;
		sparx_trdy  : buffer std_logic := '1';

		ipv4lenrx_frm  : in  std_logic;
		ipv4lenrx_irdy : in  std_logic;
		ipv4lenrx_trdy : buffer std_logic;

		icmprx_frm  : in  std_logic;
		icmprx_irdy : in  std_logic;
		icmprx_trdy : buffer std_logic := '1';
		icmprx_data : in  std_logic_vector;

		miitx_clk   : in  std_logic;

		icmptx_frm  : buffer std_logic := '0';
		icmptx_irdy : buffer std_logic := '0';
		icmptx_trdy : in  std_logic := '0';
		icmptx_data : buffer std_logic_vector);
end;

architecture def of icmpd is
	signal mode    : std_logic_vector(0 to 2-1) := "00";
	signal rx_irdy : std_logic;
	signal rx_trdy : std_logic;
	signal rx_data : std_logic_vector(icmprx_data'range);
	signal tx_irdy : std_logic;
	signal tx_trdy : std_logic;
	signal tx_data : std_logic_vector(icmptx_data'range);
begin

	sharx_trdy     <= '1';
	ipv4lenrx_trdy <= '1';
	icmprx_trdy    <= '1';

	rqst_b : block
		constant icmprx_frame : string := compact('{'                                    &
				"  type:" & string'(hdo(frames)**".format.icmp.type")   & ',' &
				"  code:" & string'(hdo(frames)**".format.icmp.code")   & ',' &
				"chksum:" & string'(hdo(frames)**".format.icmp.chksum") & '}');

		signal icmprx_acts  : std_logic_vector(0 to length(icmprx_frame));
		signal icmprx_frms  : std_logic_vector(icmprx_acts'range);
		signal icmprx_irdys : std_logic_vector(icmprx_acts'range);
		signal icmprx_trdys : std_logic_vector(icmprx_acts'range);
		alias type_act    is icmprx_acts(0);
		alias type_frm    is icmprx_frms(0);
		alias type_irdy   is icmprx_irdys(0);
		alias code_act    is icmprx_acts(1);
		alias code_frm    is icmprx_frms(1);
		alias code_irdy   is icmprx_irdys(1);
		alias chksum_act  is icmprx_acts(2);
		alias chksum_frm  is icmprx_frms(2);
		alias chksum_irdy is icmprx_irdys(2);
		signal chksum_data : std_logic_vector(icmprx_data'range);
		signal icmpchksum_irdy : std_logic;
		signal rom_irdy    : std_logic;
		signal rom_data    : std_logic_vector(icmprx_data'range);
		signal rx_frm : std_logic;
	begin
		icmprx_i : entity hdl4fpga.frame_decode
		generic map (
			frame => icmprx_frame,
			size  => icmprx_data'length)
		port map (
			clk   => miirx_clk,
			frm   => icmprx_frm,
			irdy  => icmprx_irdy,
			acts  => icmprx_acts,
			frms  => icmprx_frms,
			irdys => icmprx_irdys,
			trdys => icmprx_trdys);
		icmprx_trdys <= (others => rx_trdy);

		rom_irdy <= type_irdy or code_irdy;
		rom_i : entity hdl4fpga.sio_rom
		generic map (
			bitdata => 
				std_logic_vector'(hdo(frames)**".data.icmp.reply.type") &
				std_logic_vector'(hdo(frames)**".data.icmp.reply.code"))
		port map (
			so_clk  => miirx_clk,
			so_frm  => icmprx_frm,
			so_irdy => rom_irdy,
			so_trdy => open,
			so_data => rom_data);

		miiadjlen_i : entity hdl4fpga.mii_adjlen
		port map (
			clk     => miitx_clk,
			init    => 
				std_logic_vector'(hdo(frames)**".data.icmp.rqst.type") & 
				std_logic_vector'(hdo(frames)**".data.icmp.rqst.code"),
			frm     => icmprx_frm,
			irdy    => chksum_irdy,
			si_data => icmprx_data,
			so_irdy => icmpchksum_irdy,
			so_data => chksum_data);

		process (miirx_clk)
			variable shr_frm : unsigned(0 to 16/rx_data'length-1);
			variable shr_chksumirdy : unsigned(0 to (16/rx_data'length-1)-1);
			variable shr_irdy : unsigned(0 to 16/rx_data'length-1);
			variable shr_data : unsigned(0 to 16-1);
		begin
			if rising_edge(miirx_clk) then
				if icmpchksum_irdy='1' then
					rx_data <= chksum_data;
				else
					rx_data <= std_logic_vector(shr_data(rx_data'range));
				end if;
				if (type_act or code_act)='1' then
					shr_data(rx_data'range) := unsigned(rom_data);
				else
					shr_data(rx_data'range) := unsigned(icmprx_data);
				end if;
				icmpchksum_irdy <= shr_chksumirdy(0);
				rx_frm  <= shr_frm(0);
				rx_irdy <= shr_irdy(0);
				shr_frm(0) := icmprx_frm;
				shr_chksumirdy(0) := chksum_irdy;
				if icmprx_frm='1' then
					shr_irdy(0) := icmprx_irdy;
				else
					shr_irdy(0) := sharx_irdy or ipv4lenrx_irdy or sparx_irdy;
				end if;
				shr_frm  := rotate_left(shr_frm, 1);
				shr_chksumirdy := rotate_left(shr_chksumirdy, 1);
				shr_irdy := rotate_left(shr_irdy, 1);
				shr_data := rotate_left(shr_data, rx_data'length);
			end if;
		end process;

		process (miirx_clk)
			type states is (s_flush, s_queue);
			variable state : states;
		begin
			if rising_edge(miirx_clk) then
				if rx_frm='1' then
					mode <= "10"; -- fifo commit
				else
					case state is
					when s_flush =>
						if sharx_frm='1' then
							mode  <= "00"; -- fifo flush
							state := s_queue;
						end if;
					when s_queue =>
						mode <= "11"; --fifo queue
						if sharx_frm='0' then
							state := s_flush;
						end if;
					end case;
				end if;
			end if;
		end process;

	end block;

	buffer_i : entity hdl4fpga.fifo
	generic map(
		check_sov => true,
		check_dov => true,
		max_depth => 1024)
	port map (
		mode     => mode,
		src_clk  => miirx_clk,
		src_irdy => rx_irdy,
		src_trdy => rx_trdy,
		src_data => rx_data,
		dst_clk  => miitx_clk,
		dst_irdy => tx_irdy,
		dst_trdy => tx_trdy,
		dst_data => tx_data);

	rply_b : block
		signal lead_frm    : std_logic;
		signal chksum_frm  : std_logic;
		signal pyl_frm     : std_logic;

		signal decode_frm  : std_logic := '0';
		signal decode_irdy : std_logic := '0';
		signal decode_trdy : std_logic;
		signal decode_data : std_logic_vector(icmptx_data'range);
		signal decode_fin  : std_logic;

		signal buffer_frm  : std_logic;
		signal buffer_irdy : std_logic;
		signal buffer_trdy : std_logic;

		constant lead_length : natural := -- Latticesemi : Expecting constant string
			hdo(frames)**".format.arp.tha"   +
			hdo(frames)**".format.arp.tpa"   +
			hdo(frames)**".format.icmp.type" +
			hdo(frames)**".format.icmp.code";
		constant lead_value : string := natural'image(lead_length);
	begin

		decode_frm  <= tx_irdy;
		tx_trdy     <= decode_trdy;
		decode_data <= tx_data;

		icmptx_i : entity hdl4fpga.frame_decode
		generic map (
			frame => compact('{'     &
				"lead:" & lead_value & ',' &
				"chksum:" & string'(hdo(frames)**".format.icmp.chksum") & '}'),
			size  => icmptx_data'length)
		port map (
			clk      => miitx_clk,
			frm      => decode_frm,
			irdy     => decode_irdy,
			trdy     => decode_trdy,
			fin      => decode_fin ,
			frms(0)  => lead_frm,
			frms(1)  => chksum_frm,
			frms(2)  => pyl_frm,
			trdys(0) => buffer_trdy,
			trdys(1) => buffer_trdy,
			trdys(2) => buffer_trdy);

		buffer_frm  <= decode_frm;
		buffer_irdy <= decode_frm;
		buffer_i : entity hdl4fpga.mii_buffer
		port map (
			src_clk  => miitx_clk,
			src_frm  => buffer_frm,
			src_irdy => buffer_irdy,
			src_trdy => buffer_trdy,
			src_data => decode_data,
			dst_clk  => miitx_clk,
			dst_frm  => icmptx_frm,
			dst_irdy => icmptx_irdy,
			dst_trdy => icmptx_trdy,
			dst_data => icmptx_data);

	end block;

end;
