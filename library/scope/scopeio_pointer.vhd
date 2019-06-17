library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_pointer is
	generic (
		latency      : integer := 0);
	port (
		video_clk    : in  std_logic;
		pointer_x    : in  std_logic_vector;
		pointer_y    : in  std_logic_vector;
		video_on     : in  std_logic;
		video_hzcntr : in  std_logic_vector;
		video_vtcntr : in  std_logic_vector;
		video_dot    : out std_logic);
end;

architecture beh of scopeio_pointer is

	signal R_video_hcntr_aligned: signed(video_hzcntr'range);

	signal dot : std_logic;
begin

	process(video_clk)
	begin
		if rising_edge(video_clk) then
			if video_on='0' then
				R_video_hcntr_aligned <= to_signed(latency, video_hzcntr'length);
			else
				R_video_hcntr_aligned <= R_video_hcntr_aligned+1;
			end if;
	video_dot <= setif(R_video_hcntr_aligned = signed(pointer_x) or video_vtcntr = pointer_y);
		end if;
	end process;

end;
