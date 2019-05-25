library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library hdl4fpga;

entity scopeio_pointer is
	generic (
		latency     : natural);

	port (
		video_clk   : in  std_logic;
		pointer_x   : in  std_logic_vector;
		pointer_y   : in  std_logic_vector;
		video_on    : in  std_logic;
		video_hcntr : in  std_logic_vector;
		video_vcntr : in  std_logic_vector;
		video_dot   : out std_logic);
end;

architecture beh of scopeio_pointer is

	signal R_video_hcntr_aligned: signed(video_hcntr'range);

	signal dot : std_logic;
begin

	process(video_clk)
	begin
		if rising_edge(video_clk) then
			if video_on='0' then
			else
				R_video_hcntr_aligned <= R_video_hcntr_aligned+1;
			end if;
		end if;
	end process;

	video_dot <= '1' when R_video_hcntr_aligned = signed(pointer_x) or video_vcntr = pointer_y else '0';

                                       --
--	dot <= '1' when video_hcntr = pointer_x or video_vcntr = pointer_y else '0';
--	latency_e : entity hdl4fpga.align
--	generic map (
--		n => 1,
--		d => (0 => latency))
--	port map (
--		clk => video_clk,
--		di(0) => dot,
--		do(0) => video_dot);

end;
