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

library hdl4fpga;
use hdl4fpga.base.all;

architecture dbdbbl_tb of testbench is
	signal bcd : std_logic_vector(5*4-1 downto 0);
begin
	du_e : entity hdl4fpga.dbdbbl_sllfix
	port map (
		bin => std_logic_vector(to_unsigned(32035,15)), -- b"1001110",
		ini => "0",
		bcd => bcd);

	process (bcd)
	begin
		report to_string(bcd);
	end process;

end;

library ieee;
use ieee.std_logic_1164.all;

library hdl4fpga;
use hdl4fpga.base.all;

architecture dbdbbl_srlfix_tb of testbench is
	signal bcd : std_logic_vector(6*4-1 downto 0);
	signal bin : std_logic_vector(0 to 4-1);
begin
	du_e : entity hdl4fpga.dbdbbl_srlfix
	port map (
		rnd => '0',
		ini => b"0001_0010_0000",
		bin => bin,
		bcd => bcd);
end;

library ieee;
use ieee.std_logic_1164.all;

library hdl4fpga;
use hdl4fpga.base.all;

architecture dbdbbl_srl_tb of testbench is
	signal bcd : std_logic_vector(6*4-1 downto 0);
	signal cnt : std_logic_vector(0 to 3-1);
	signal bin : std_logic_vector(0 to 6-1);
begin
	du_e : entity hdl4fpga.dbdbbl_srl
	port map (
		ini => x"31",
		cnt => b"101",
		bin => bin,
		bcd => bcd);
end;

library ieee;
use ieee.std_logic_1164.all;

library hdl4fpga;
use hdl4fpga.base.all;

architecture dbdbblsrlser_tb of testbench is
	constant bcd_length : natural := 4;
	constant bcd_width  : natural := 7;
	constant bcd_digits : natural := 1;
	constant bin_digits : natural := 5;

	signal clk  : std_logic := '0';
	signal frm  : std_logic := '0';
	signal ini  : std_logic_vector(bcd_length*bcd_digits-1 downto 0);
	signal bcd  : std_logic_vector(bcd_length*bcd_digits-1 downto 0);
begin
	clk <= not clk after 1 ns;

	process (clk)
		constant num  : unsigned := x"111100";
		variable var  : unsigned(0 to bcd_length*bcd_width-1);
	begin
		if rising_edge(clk) then
			if frm='1' then
				frm <= '1';
				var := shift_left(var, ini'length);
			else
				var := (others => '0');
				var(num'range) := num;
				frm <= '1';
			end if;
			ini <= std_logic_vector(var(0 to ini'length-1));
		end if;
	end process;

	du_e : entity hdl4fpga.dbdbblsrl_ser
	generic map (
		max_count  => bin_digits,
		bcd_width  => bcd_width,
		bcd_digits => bcd_digits)
	port map (
		clk => clk,
		frm => frm,
		cnt => b"101",
		bcd_ini => ini,
		bcd => bcd);
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;

architecture dbdbbl_seq_tb of testbench is
	constant bcd_length : natural := 4;
	constant bcd_digits : natural := 1;
	constant bin_digits : natural := 3;

	signal clk  : std_logic := '0';
	signal req  : std_logic := '0';
	signal rdy  : std_logic := '1';
	signal bcd  : std_logic_vector(bcd_length*bcd_digits-1 downto 0);
begin
	clk <= not clk after 1 ns;

	process (clk)
	begin
		if rising_edge(clk) then
			if req='0' then
				req <= '1';
			end if;
		end if;
	end process;
	-- req <= not to_stdulogic(to_bit(rdy));

	du_e : entity hdl4fpga.dbdbbl_seq
	generic map (
		bcd_width  => 5,
		bin_digits => bin_digits,
		bcd_digits => bcd_digits)
	port map (
		clk => clk,
		req => req,
		rdy => rdy,
		bin => std_logic_vector(to_unsigned(32035,15)), -- b"1001110",
		bcd => bcd);

	process (bcd)
	begin
		-- report to_string(bcd);
	end process;

end;


