library iocore;
library ieee;
use ieee.std_logic_1164.all;
    
entity testbench is
end;

architecture def of testbench is
    signal clk : std_logic := '1';
    signal mode : std_logic_vector(0 downto 0);
	signal disp : std_logic;
	signal hsync : std_logic;
	signal vsync : std_logic;
	signal row : std_logic_vector(5-1 downto 0);
	signal col : std_logic_vector(5-1 downto 0);
 begin
    du : entity iocore.video_vga_sync
    generic map (
        n => 5,
        m => 1)
    port map (
        clk => clk,
        mode => "0",
        disp => disp,
        hsync => hsync,
        vsync => vsync,
        row => row,
        col => col);
    clk <= not clk after 5 ns;


end;
