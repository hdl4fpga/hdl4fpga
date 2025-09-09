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

		tharx_frm   : in  std_logic;
		tharx_irdy  : in  std_logic;
		tharx_trdy  : buffer std_logic := '1';

		tparx_frm   : in  std_logic;
		tparx_irdy  : in  std_logic;
		tparx_trdy  : buffer std_logic := '1';

		icmprx_frm  : in  std_logic;
		icmprx_irdy : in  std_logic;
		icmprx_trdy : buffer std_logic := '1';
		icmprx_data : in  std_logic_vector;

		miitx_clk   : in  std_logic;

		thatx_frm   : buffer std_logic;
		thatx_irdy  : buffer std_logic;
		thatx_trdy  : in  std_logic := '1';

		tpatx_frm   : buffer std_logic;
		tpatx_irdy  : buffer std_logic;
		tpatx_trdy  : in  std_logic := '1';

		icmptx_frm  : buffer std_logic := '0';
		icmptx_irdy : buffer std_logic := '0';
		icmptx_trdy : in  std_logic := '0';
		icmptx_data : out std_logic_vector);
end;

architecture def of icmpd is
	signal co      : std_logic;

	signal tx_req  : std_logic := '0';
	signal tx_rdy  : std_logic := '0';
	signal wr_data : std_logic_vector(icmprx_data'range);
	signal rd_data : std_logic_vector(icmptx_data'range);
begin

	rqst_b : block
		signal type_frm   : std_logic;
		signal code_frm   : std_logic;
		signal chksum_frm : std_logic;
		signal id_frm     : std_logic;
		signal seq_frm    : std_logic;
		signal pyl_frm    : std_logic;
	begin
		icmprx_i : entity hdl4fpga.frame_decode
		generic map (
			frame => hdo(frames)**".format.icmp",
			size  => icmprx_data'length)
		port map (
			clk    => miirx_clk,
			frm    => icmprx_frm,
			irdy   => icmprx_irdy,
			act(0) => type_frm,
			act(1) => code_frm,
			act(2) => chksum_frm,
			act(3) => id_frm,
			act(4) => seq_frm,
			act(5) => pyl_frm);

		chksum_b : block
			alias  chksum_irdy is chksum_frm;
			signal adj_data : std_logic_vector(icmprx_data'range);
		begin

			rom_i : entity hdl4fpga.sio_rom
			generic map (
				bitdata => 
					std_logic_vector'(hdo(frames)**".data.icmp.rqst.type") &
					std_logic_vector'(hdo(frames)**".data.icmp.rqst.code"))
			port map (
				so_clk  => miirx_clk,
				so_frm  => chksum_frm,
				so_irdy => chksum_irdy,
				so_trdy => open,
				so_data => adj_data);

			process (icmprx_frm,miirx_clk)
				variable cy  : std_logic;
				variable sum : unsigned(0 to icmprx_data'length+1);
				variable op1 : unsigned(sum'range);
				variable op2 : unsigned(sum'range);
			begin
				if rising_edge(miirx_clk) then
					op1 := unsigned('0' & reverse(icmprx_data) & '1');
					op2 := unsigned('0' & adj_data             & cy);
					sum := op1 + op2;
					if chksum_frm='1' then
						wr_data <= std_logic_vector(sum(1 to icmprx_data'length));
					else
						wr_data <= icmprx_data;
					end if;
					if chksum_frm='1' then
						cy := sum(0);
					elsif icmprx_frm='1' then
						co <= cy;
					else
						cy := '0';
					end if;
				end if;
			end process;
		end block;

		process (miirx_clk)
		begin
			if rising_edge(miirx_clk) then
				if (tx_req xor tx_rdy)='0' then
					if icmprx_frm='1' then
						tx_req <= not tx_rdy;
					end if;
				end if;
			end if;
		end process;

	end block;

	mem_b : block
		signal wr_addr : std_logic_vector(0 to 4) := (others => '0');
		signal rd_addr : std_logic_vector(0 to 4) := (others => '0');
	begin
		process (miirx_clk)
			variable active : std_logic;
			variable cntr   : unsigned(wr_addr'range) := (others => '0');
		begin
			if rising_edge(miirx_clk) then
				wr_addr <= std_logic_vector(cntr);
				if (tharx_irdy and tharx_trdy)='1' then
					cntr := cntr + 1;
				elsif (tparx_irdy and tparx_trdy)='1' then
					cntr := cntr + 1;
				elsif (icmprx_irdy and icmprx_trdy)='1' then
					cntr := cntr + 1;
				end if;
				if (icmprx_irdy and icmprx_trdy)='1' then
					active := '1';
				elsif active='1' then
					active := '0';
				end if;
			end if;
		end process;

		data_i : entity hdl4fpga.dpram
		port map (
			wr_clk  => miirx_clk,
			wr_addr => wr_addr,
			wr_data => wr_data,
			rd_clk  => miitx_clk,
			rd_addr => rd_addr,
			rd_data => rd_data);

		icmptx_data <= rd_data;
		process (miitx_clk)
			variable active : std_logic;
			variable cntr   : unsigned(rd_addr'range) := (others => '0');
		begin
			if rising_edge(miitx_clk) then
				if (icmptx_frm or (icmptx_irdy and icmptx_trdy))='1' then
					rd_addr <= std_logic_vector(cntr);
					cntr    := cntr + 1;
					active  := '1';
				elsif active='1' then
					active  := '0';
				end if;
			end if;
		end process;

	end block;

	rply_b : block
		signal type_frm   : std_logic;
		signal code_frm   : std_logic;
		signal chksum_frm : std_logic;
		signal id_frm     : std_logic;
		signal seq_frm    : std_logic;
		signal pyl_frm    : std_logic;

		signal decode_frm  : std_logic;
		signal decode_irdy : std_logic;
		signal decode_trdy : std_logic;
		signal decode_last : std_logic;
		signal decode_fin  : std_logic;
		signal decode_data : std_logic_vector(icmptx_data'range);

	begin

		process (miirx_clk)
			type states is (s_tha, s_tpa, s_icmp);
			variable state : states;
		begin
			if rising_edge(miirx_clk) then
				if (tx_req xor tx_rdy)='1' then

					case state is
					when s_tha  => 
						if thatx_irdy='0' then
							mem_irdy ='1';
							thatx_irdy 
						elsif (thatx_irdy and thatx_trdy)='1' then
						end if;
					when s_tpa  =>
					when s_icmp =>
					end case;
				end if;
			end if;
		end process;

		decode_irdy <= '1';
		icmptx_i : entity hdl4fpga.frame_decode
		generic map (
			frame => hdo(frames)**".format.icmp",
			size  => icmptx_data'length)
		port map (
			clk    => miitx_clk,
			frm    => decode_frm,
			irdy   => decode_irdy,
			act(0) => type_frm,
			act(1) => code_frm,
			act(2) => chksum_frm,
			act(3) => id_frm,
			act(4) => seq_frm,
			act(5) => pyl_frm);

		chksumtx_b : block
		begin
			process (miitx_clk)
				variable sum : unsigned(0 to icmptx_data'length+1);
				variable op1 : unsigned(sum'range);
				variable op2 : unsigned(sum'range);
				variable cy  : std_logic;
			begin
				if rising_edge(miitx_clk) then
					op1 := unsigned'('0' & (icmptx_data'range => '0') & '1');
					op2 := unsigned'('0' & (icmptx_data'range => '0') & cy);
					sum := op1 + op2;
					if icmptx_frm='0' then
						cy := '0';
					elsif chksum_frm='1' then
						cy := sum(0);
					end if;
				end if;
			end process;
		end block;

		decode_data <= rd_data;
		frm_p : process (miitx_clk)
		begin
			if rising_edge(miitx_clk) then
				if decode_frm='0' then
					icmptx_frm <= '0';
				else
					icmptx_frm <= decode_frm and not decode_last;
				end if;
			end if;
		end process;

		irdy_p : process (miitx_clk)
		begin
			if rising_edge(miitx_clk) then
				if (not icmptx_frm and (icmptx_irdy and icmptx_trdy))='1' then
					icmptx_irdy <= '0';
				elsif not decode_last='1' then
					icmptx_irdy <= decode_irdy;
				end if;
			end if;
		end process;

		data_p : process (miitx_clk)
		begin
			if rising_edge(miitx_clk) then
				if (decode_irdy and icmptx_trdy)='1' then
					icmptx_data <= decode_data;
				elsif (decode_irdy and not icmptx_irdy)='1'then
					icmptx_data <= decode_data;
				end if;
			end if;
		end process;

	end block;

end;
