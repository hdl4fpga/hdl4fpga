entity scopeio
==============

generic
-------

============== ================ ==============
inputs         natural          1
input_preamp   real_vector
layout_id      natural          0
vt_div         std_logic_vector b"0_0010_0000"
ht_div         std_logic_vector b"0_0010_0000"
hz_scales      scale_vector
vt_scales      scale_vector
gauge_labels   std_logic_vector
unit_symbols   std_logic_vector
channels_fg    std_logic_vector
channels_bg    std_logic_vector
hzaxis_fg      std_logic_vector
hzaxis_bg      std_logic_vector
grid_fg        std_logic_vector
grid_bg        std_logic_vector
============== ================ ==============

.. comment
	port (
		mii_rxc     : in  std_logic := '-';
		mii_rxdv    : in  std_logic := '0';
		mii_rxd     : in  std_logic_vector;
		tdiv        : out std_logic_vector(4-1 downto 0);
		cmd_rdy     : in  std_logic := '0';
		channel_ena : in  std_logic_vector(0 to inputs-1) := (others => '1');
		input_clk   : in  std_logic;
		input_ena   : in  std_logic := '1';
		input_data  : in  std_logic_vector;
		video_clk   : in  std_logic;
		video_rgb   : out std_logic_vector;
		video_hsync : out std_logic;
		video_vsync : out std_logic;
		video_blank : out std_logic;
		video_sync  : out std_logic);
    end;

