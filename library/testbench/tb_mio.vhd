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

library hdl4fpga;

architecture tb_mio of testbench is
	signal clk : std_logic := '0';
	signal req : std_logic := '0';
	signal rdy : std_logic := '0';
	signal mdio : std_logic := 'H';
	signal mdt : std_logic := 'H';
begin
	clk <= not clk after 5 ns;
	process (clk)
	begin
		if rising_edge(clk) then
			if (req xor rdy)='0' then
				req <= not rdy;
			end if;
		end if;
	end process;

	mdio <= 'H' when mdt='0' else '0';
	du_e : entity hdl4fpga.mdio
	port map (
		clk  => clk,
		req  => req,
		rdy  => rdy,
		dev  => b"00001",
		rid  => b"00000",
		din  => x"1200",
		mdt  => mdt,
		mdi  => mdio);
end;
