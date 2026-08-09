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
		ipv4lenrx_trdy : buffer std_logic := '1';

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
	signal tx_req  : std_logic := '0';
	signal tx_rdy  : std_logic := '0';
	signal wr_addr : std_logic_vector(0 to 10-1);
	signal wr_data : std_logic_vector(icmprx_data'range);
	signal wr_ena  : std_logic;
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
		signal framedecode_trdy : std_logic;
	begin
		icmprx_i : entity hdl4fpga.frame_decode
		generic map (
			frame => compact('{'                                              &
				"  type:" & string'(hdo(frames)**".format.icmp.type")   & ',' &
				"  code:" & string'(hdo(frames)**".format.icmp.code")   & ',' &
				"chksum:" & string'(hdo(frames)**".format.icmp.chksum") & '}'),
			size  => icmprx_data'length)
		port map (
			clk    => miirx_clk,
			frm    => icmprx_frm,
			irdy   => icmprx_irdy,
			trdy  => framedecode_trdy, -- Latticesemi complains : Port trdy cannot be connected to a constant
			frms(0) => type_frm,
			frms(1) => code_frm,
			frms(2) => chksum_frm,
			frms(3) => pyl_frm);

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
							op1 := unsigned('0' & reverse(icmprx_data) & '1');
							op2 := unsigned('0' & reverse(chksum_miib) & cy);
							sum := op1 + op2;
							cy  := sum(0);
							chksum_diff <= rotate_left(chksum_diff, icmprx_data'length);
						end if;
					else
						cy := '0';
						chksum_diff <=
							reverse((hdo(frames)**".data.icmp.rqst.type")) &
							reverse((hdo(frames)**".data.icmp.rqst.code"));
					end if;

					if (chksum_frm and icmprx_irdy)='1' then
						wr_data <= std_logic_vector(reverse(sum(1 to icmprx_data'length)));
					elsif ((type_frm or code_frm) and icmprx_irdy)='1' then
						wr_data <= rom_data;
					else 
						wr_data <= icmprx_data;
					end if;
				end if;
			end process;
		end block;

		process (icmprx_irdy, miirx_clk)
			variable cntr : unsigned(wr_addr'range) := (others => '0');
			variable init : boolean;
		begin
			if rising_edge(miirx_clk) then
				if sharx_frm='1' then
					if (sharx_irdy and sharx_trdy)='1' then
						if not init then
							init := true;
							cntr := (others => '0');
						else
							cntr := cntr + 1;
						end if;
						wr_ena <= '1';
					end if;
				else 
					init := false;
					if (sparx_irdy and sparx_trdy)='1' then
						cntr := cntr + 1;
						wr_ena <= '1';
					elsif (icmprx_irdy and icmprx_trdy)='1' then
						cntr := cntr + 1;
						wr_ena <= '1';
					elsif (ipv4lenrx_irdy and ipv4lenrx_trdy)='1' then
						cntr := cntr + 1;
						wr_ena <= '1';
					else
						wr_ena <= '0';
					end if;
				end if;
				wr_addr <= std_logic_vector(cntr);
			end if;
		end process;

		process (miitx_clk)
		begin
			if rising_edge(miitx_clk) then
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
		wr_ena  => wr_ena,
		wr_addr => wr_addr,
		wr_data => wr_data,
		rd_clk  => miitx_clk,
		rd_addr => rd_addr,
		rd_data => rd_data);

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

		-- signal eq_addr : boolean;
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
			variable cntr : unsigned(rd_addr'range) := (others => '0');
		begin
			if rising_edge(miitx_clk) then
				if ((decode_frm or decode_trdy) and decode_irdy)='1' then
					cntr := cntr + 1;
				elsif (icmptx_frm or icmptx_irdy)='0' then
					cntr := (others => '0');
				end if;
				-- eq_addr <= std_logic_vector(cntr) = wr_addr;
				rd_addr <= std_logic_vector(cntr);
			end if;
		end process;

		icmptx_i : entity hdl4fpga.frame_decode
		generic map (
			frame => compact('{'                                        &
				"lead:" & natural'image(
					hdo(frames)**".format.arp.tha"   +
					hdo(frames)**".format.arp.tpa"   +
					hdo(frames)**".format.icmp.type" +
					hdo(frames)**".format.icmp.code")                   & ',' &
				"chksum:" & string'(hdo(frames)**".format.icmp.chksum") & '}'),
			size  => icmptx_data'length)
		port map (
			clk    => miitx_clk,
			frm    => decode_frm,
			irdy   => decode_irdy,
			fin    => decode_fin ,
			frms(0) => lead_frm,
			frms(1) => chksum_frm,
			frms(2) => pyl_frm);

		buffer_frm  <= decode_frm when unsigned(rd_addr) /= unsigned(wr_addr) else '0';
		-- buffer_frm  <= decode_frm when eq_addr else '0';
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
			dst_trdy => icmptx_trdy,
			dst_data => icmptx_data);

	end block;

end;
