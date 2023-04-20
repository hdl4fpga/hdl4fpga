library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;

architecture beh of testbench is
    signal frm   : std_logic;
    signal clk   : std_logic := '0';
    signal pixel : std_logic_vector(3*10-1 downto 0);
    signal q     : std_logic_vector(3*7-1  downto 0);
begin
    frm <= '0', '1' after 20 ns;
    clk <= not clk after 10 ns;

    pixel <= "0000011111" & "1100110011" & "0011001100";
    g : for i in 0 to 3-1 generate
        signal subpixel : unsigned(7-1 downto 0);
    begin

        subpixel <= resize(rotate_left(unsigned(pixel), i*subpixel'length), subpixel'length);
        du_e : entity hdl4fpga.serlzr
        port map (
            in_frm   => frm,
            in_clk   => clk,
            in_data  => std_logic_vector(subpixel),
            out_data => q((i+1)*7-1 downto i*7));
    end generate;

end;