entity scopeio
==============

generic
-------

===================  ================ ============== ===========================
Parameter            Type             Default        Description
===================  ================ ============== ===========================
:ref:`inputs`        natural          1              Number of channel inputs
:ref:`input_preamp`  real_vector                     Analog input Preamplifier  
layout_id            natural          0              Display layouts 
vt_div               std_logic_vector b"0_0010_0000" Vertical division unit
ht_div               std_logic_vector b"0_0010_0000" Horizontal division unit
hz_scales            scale_vector                    Horizontal scale descriptor 
vt_scales            scale_vector                    Vertical scale descriptor
gauge_labels         std_logic_vector                Gauge labels
unit_symbols         std_logic_vector                Unit Symbols
channels_fg          std_logic_vector                Channel foreground colors
channels_bg          std_logic_vector                Channel background colors
hzaxis_fg            std_logic_vector                Horzontal foreground colors
hzaxis_bg            std_logic_vector                Horzontal background colors
grid_fg              std_logic_vector                Grid foreground colors
grid_bg              std_logic_vector                Grid background colors
===================  ================ ============== ===========================

.. _inputs: 

inputs
~~~~~~

The number of channel inputs which scopeio is going to plot.

.. _input_preamp: 

input_preamp
~~~~~~~~~~~~

This parameter is requiered to set when the analog inputs have different scales




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

