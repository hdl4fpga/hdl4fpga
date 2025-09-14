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

		thatx_frm   : in  std_logic;
		thatx_irdy  : in  std_logic;
		thatx_trdy  : out std_logic := '1';
		thatx_data  : out std_logic_vector;

		tpatx_frm   : in  std_logic;
		tpatx_irdy  : in  std_logic;
		tpatx_trdy  : out std_logic := '1';
		tpatx_data  : out std_logic_vector;

		icmptx_frm  : buffer std_logic := '0';
		icmptx_irdy : buffer std_logic := '0';
		icmptx_trdy : in  std_logic := '0';
		icmptx_data : buffer std_logic_vector);
end;

architecture def of icmpd is
	signal co      : std_logic;

	signal tx_req  : std_logic := '0';
	signal tx_rdy  : std_logic := '0';
	signal wr_addr : std_logic_vector(0 to 10-1);
	signal wr_data : std_logic_vector(icmprx_data'range);
	signal cmp_addr : unsigned(wr_addr'range);
	signal rd_addr : std_logic_vector(wr_addr'range);
	signal rd_data : std_logic_vector(icmptx_data'range);
begin

	rqst_b : block
		signal type_frm   : std_logic;
		signal code_frm   : std_logic;
		signal chksum_frm : std_logic;
		signal pyl_frm    : std_logic;
		signal rom_frm  : std_logic;
		alias  rom_irdy is icmprx_irdy;
		signal rom_data : std_logic_vector(icmprx_data'range);
	begin
		icmprx_i : entity hdl4fpga.frame_decode
		generic map (
			frame => '{'                                                      &
				"  type:" & string'(hdo(frames)**".format.icmp.type")   & ',' &
				"  code:" & string'(hdo(frames)**".format.icmp.code")   & ',' &
				"chksum:" & string'(hdo(frames)**".format.icmp.chksum") & '}',
			size  => icmprx_data'length)
		port map (
			clk    => miirx_clk,
			frm    => icmprx_frm,
			irdy   => icmprx_irdy,
			act(0) => type_frm,
			act(1) => code_frm,
			act(2) => chksum_frm,
			act(3) => pyl_frm);

		rom_frm <= type_frm or code_frm;
		rom_i : entity hdl4fpga.sio_rom
		generic map (
			bitdata => 
				std_logic_vector'(hdo(frames)**".data.icmp.reply.type") &
				std_logic_vector'(hdo(frames)**".data.icmp.reply.code"))
		port map (
			so_clk  => miirx_clk,
			so_frm  => rom_frm,
			so_irdy => rom_irdy,
			so_trdy => open,
			so_data => rom_data);

		chksum_b : block
			alias  chksum_irdy is icmprx_irdy;
			signal chksum_diff : unsigned(0 to hdo(frames)**".format.icmp.chksum"-1);
			alias  chksum_miib : unsigned(icmprx_data'range) is chksum_diff(0 to icmprx_data'length-1);
		begin
			process (icmprx_frm, miirx_clk)
				variable cy  : std_logic;
				variable sum : unsigned(0 to icmprx_data'length+1);
				variable op1 : unsigned(sum'range);
				variable op2 : unsigned(sum'range);
			begin
				if rising_edge(miirx_clk) then
					if icmprx_frm='1' then
						if (chksum_frm and chksum_irdy)='1' then
							cy := sum(0);
							co <= cy;
							chksum_diff <= rotate_left(chksum_diff, icmprx_data'length);
						end if;
					else
						chksum_diff <=
							resize(unsigned'(hdo(frames)**".data.icmp.rqst.type"), chksum_diff'length) + 
							resize(unsigned'(hdo(frames)**".data.icmp.rqst.code"), chksum_diff'length);
						cy := '0';
					end if;
					op1 := unsigned('0' & reverse(icmprx_data) & '1');
					op2 := unsigned('0' & chksum_miib          & cy);
					sum := op1 + op2;

					if (chksum_frm and icmprx_irdy)='1' then
						wr_data <= std_logic_vector(sum(1 to icmprx_data'length));
					elsif ((type_frm or code_frm) and icmprx_irdy)='1' then
						wr_data <= rom_data;
					else 
						wr_data <= icmprx_data;
					end if;
				end if;
			end process;
		end block;

		process (miirx_clk)
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
			end if;
		end process;

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

	data_i : entity hdl4fpga.dpram
	port map (
		wr_clk  => miirx_clk,
		wr_addr => wr_addr,
		wr_data => wr_data,
		rd_clk  => miitx_clk,
		rd_addr => rd_addr,
		rd_data => rd_data);

	rply_b : block
		signal lead_frm    : std_logic;
		signal chksum_frm  : std_logic;
		signal pyl_frm     : std_logic;

		signal decode_frm  : std_logic;
		signal decode_irdy : std_logic;
		signal decode_trdy : std_logic;
		signal decode_data : std_logic_vector(icmptx_data'range);
		signal decode_fin  : std_logic;

		signal buffer_frm  : std_logic;
		signal buffer_irdy : std_logic;
		signal buffer_trdy : std_logic;

	begin

		process (miitx_clk)
		begin
			if rising_edge(miitx_clk) then
				if (tx_req xor tx_rdy)='1' then
					if decode_fin='0' then
						decode_frm <= '1';
					elsif icmptx_frm='1' then
						decode_frm <= '1';
					elsif (icmptx_irdy and not icmptx_trdy)='1' then
						decode_frm <= '1';
					else
						decode_frm <= '0';
						tx_rdy <= tx_req;
					end if;
				else
					decode_frm <= '0';
				end if;
			end if;
		end process;

		decode_irdy <= 
			decode_trdy when   lead_frm='1' else
			decode_trdy when chksum_frm='1' else
			decode_trdy when    pyl_frm='1' else
			'0';
		decode_data <= rd_data;

		process (rd_addr , miitx_clk)
			variable cntr   : unsigned(rd_addr'range) := (others => '0');
		begin
			if rising_edge(miitx_clk) then
				if ((decode_frm or decode_trdy) and decode_irdy)='1' then
					cntr := cntr + 1;
				end if;
				rd_addr <= std_logic_vector(cntr);
			end if;
		end process;

		icmptx_i : entity hdl4fpga.frame_decode
		generic map (
			frame => '{'                                                &
				"lead:" & natural'image(
					hdo(frames)**".format.arp.tha"   +
					hdo(frames)**".format.arp.tpa"   +
					hdo(frames)**".format.icmp.type" +
					hdo(frames)**".format.icmp.code")                   & ',' &
				"chksum:" & string'(hdo(frames)**".format.icmp.chksum") & '}',
			size  => icmptx_data'length)
		port map (
			clk    => miitx_clk,
			frm    => decode_frm,
			irdy   => decode_irdy,
			fin    => decode_fin ,
			act(0) => lead_frm,
			act(1) => chksum_frm,
			act(2) => pyl_frm);

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

		buffer_frm  <= decode_frm when unsigned(rd_addr) /= unsigned(wr_addr)-1 else '0';
		buffer_irdy <= decode_frm;
		buffer_i : entity hdl4fpga.mii_buffer
		port map (
			clk => miitx_clk,
			src_frm  => buffer_frm,
			src_irdy => buffer_irdy,
			src_trdy => decode_trdy,
			src_data => decode_data,
			dst_frm  => icmptx_frm,
			dst_irdy => icmptx_irdy,
			dst_trdy => buffer_trdy,
			dst_data => icmptx_data);

		buffer_trdy <= 
			thatx_irdy when thatx_frm='1' else
			tpatx_irdy when tpatx_frm='1' else
			icmptx_trdy;
		thatx_trdy <= thatx_irdy;
		thatx_data <= icmptx_data;
		tpatx_trdy <= tpatx_irdy;
		tpatx_data <= icmptx_data;

	end block;

end;
