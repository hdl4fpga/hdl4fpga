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
		icmprx_frm  : in  std_logic;
		icmprx_irdy : in  std_logic;
		icmprx_trdy : buffer std_logic := '1';
		icmprx_data : in  std_logic_vector;

		miitx_clk   : in  std_logic;
		icmptx_frm  : buffer std_logic;
		icmptx_irdy : buffer std_logic;
		icmptx_trdy : in  std_logic := '0';
		icmptx_data : out std_logic_vector);
end;

architecture def of icmpd is
	signal cyrx         : std_logic;

	signal tx_req      : std_logic := '0';
	signal tx_rdy      : std_logic := '0';
begin

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

			process (miirx_clk)
				variable sum : unsigned(0 to icmprx_data'length+1);
				variable op1 : unsigned(sum'range);
				variable op2 : unsigned(sum'range);
			begin
				if rising_edge(miirx_clk) then
					op1 := unsigned('0' & reverse(icmprx_data) & '1');
					op2 := unsigned('0' & adj_data             & cyrx);
					sum := op1 + op2;
					if icmprx_frm='0' then
						cyrx <= '0';
					elsif chksum_frm='1' then
						cyrx <= sum(0);
					end if;
				end if;
			end process;
		end block;
	end block;

	process (miirx_clk, miitx_clk)
		type arrange is array(natural range <>) of std_logic_vector(icmprx_data'range);
		variable rx_cntr : unsigned(0 to 4);
		variable tx_cntr : unsigned(rx_cntr'range);
		variable mem : arrange(0 to 4);
	begin
		if rising_edge(miirx_clk) then
			if (icmprx_frm or (icmprx_irdy and icmprx_trdy))='1' then
				mem(to_integer(rx_cntr)) := icmprx_data;
				rx_cntr := rx_cntr + 1;
			end if;
		end if;
		if rising_edge(miitx_clk) then
			if (tx_rdy xor tx_req)='1' then
				icmptx_frm  <= '1';
				icmptx_irdy <= '1';
				icmptx_data <= mem(to_integer(tx_cntr));
				tx_cntr     := tx_cntr + 1;
			end if;
		end if;
	end process;

	rply_b : block
		signal type_frm   : std_logic;
		signal code_frm   : std_logic;
		signal chksum_frm : std_logic;
		signal id_frm     : std_logic;
		signal seq_frm    : std_logic;
		signal pyl_frm    : std_logic;
	begin

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
					op2 := unsigned'('0' & "0"             & cy);
					sum := op1 + op2;
					if icmptx_frm='0' then
						cy := '0';
					elsif chksum_frm='1' then
						cy := sum(0);
					end if;
				end if;
			end process;
		end block;

		icmptx_i : entity hdl4fpga.frame_decode
		generic map (
			frame => hdo(frames)**".format.icmp",
			size  => icmptx_data'length)
		port map (
			clk    => miitx_clk,
			frm    => icmptx_frm,
			irdy   => icmptx_irdy,
			act(0) => type_frm,
			act(1) => code_frm,
			act(2) => chksum_frm,
			act(3) => id_frm,
			act(4) => seq_frm,
			act(5) => pyl_frm);

	end block;

end;
