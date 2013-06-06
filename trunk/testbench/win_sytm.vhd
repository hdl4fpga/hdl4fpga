use std.textio.all;

library ieee;
use ieee.std_logic_textio.all;

architecture win_sytm of testbench is
	constant n : natural := 11;

	signal video_clk  : std_logic := '0';

	signal vga_don : std_logic;
	signal vga_frm : std_logic;

	signal win_rowid : std_logic_vector(2-1 downto 0);
	signal win_rowpag : std_logic_vector(5-1 downto 0);
    signal win_rowoff : std_logic_vector(6-1 downto 0);
    signal win_colid : std_logic_vector(2-1 downto 0);
    signal win_colpag : std_logic_vector(2-1 downto 0);
    signal win_coloff : std_logic_vector(12-1 downto 0);
begin

	video_clk <= not video_clk after 500 ns/150 ;

	video_vga_e : entity work.video_vga
	generic map (
		n => 12)
	port map (
		clk   => video_clk,
		frm   => vga_frm,
		don   => vga_don);

	win_sytm_e : entity work.win_sytm
	port map (
		win_clk => video_clk,
		win_don => vga_don,
		win_frm => vga_frm,
		win_rowid => win_rowid,
		win_rowpag => win_rowpag,
        win_rowoff => win_rowoff,
        win_colid => win_colid,
        win_colpag => win_colpag,
        win_coloff => win_coloff);

end;
