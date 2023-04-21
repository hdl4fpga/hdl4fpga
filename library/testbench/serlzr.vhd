library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;

architecture serlzr of testbench is
    signal frm   : std_logic;
    signal clk   : std_logic := '0';
    signal pixel : std_logic_vector(3*10-1 downto 0);
    signal q     : std_logic_vector(3*7-1  downto 0);

    alias red   : std_logic_vector(7-1 downto 0) is q( 7-1 downto 0);
    alias green : std_logic_vector(7-1 downto 0) is q(14-1 downto 7);
    alias blue  : std_logic_vector(7-1 downto 0) is q(21-1 downto 14);
begin
    frm <= '0', '1' after 20 ns;
    clk <= not clk after 10 ns;

    pixel <= "0000011111" & "1100110011" & "0011001100";
    g : for i in 0 to 3-1 generate
        du_e : entity hdl4fpga.serlzr
        port map (
            in_frm   => frm,
            in_clk   => clk,
            in_data  => pixel((i+1)*10-1 downto i*10),
            out_data => q((i+1)*7-1 downto i*7));
    end generate;

end;