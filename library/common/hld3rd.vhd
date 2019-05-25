package hdl3rd is

	component scopeio_pointer is
		generic (
			latency : natural);
		port (
			video_clk     : in  std_logic;
			video_on      : in  std_logic;
			video_hcntr   : in  std_logic_vector;
			video_vcntr   : in  std_logic_vector;
			pointer_color : out std_logic_vector);
	end component;
	
end;
