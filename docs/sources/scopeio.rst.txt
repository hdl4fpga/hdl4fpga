entity scopeio
==============

.. comment: .. raw:: html
    <object with="80" data="input_data.svg" type="image/svg+xml"></object>

.. image:: scopeio.svg
   :target: images/scopeio.svg

generic
-------

=================== =================== ============== ===========================
Parameter           Type                Default        Description
=================== =================== ============== ===========================
:ref:`inputs`       natural             1              Number of channel inputs
:ref:`input_preamp` real_vector                        Analog input Preamplifier  
:ref:`layout_id`    natural             0              Display layouts 
:ref:`vt_div`       std_logic_vector    b"0_001_00000" Vertical division unit
:ref:`hz_div`       std_logic_vector    b"0_001_00000" Horizontal division unit
:ref:`vt_scales`    :ref:`scale_vector`                Vertical scale descriptor
:ref:`hz_scales`    :ref:`scale_vector`                Horizontal scale descriptor 
:ref:`gauge_labels` std_logic_vector                   Gauge labels
:ref:`unit_symbols` std_logic_vector                   Unit Symbols
:ref:`channels_fg`  std_logic_vector                   Channel foreground colors
:ref:`channels_bg`  std_logic_vector                   Channel background colors
:ref:`hzaxis_fg`    std_logic_vector                   Horzontal foreground color
:ref:`hzaxis_bg`    std_logic_vector                   Horzontal background color
:ref:`grid_fg`      std_logic_vector                   Grid foreground colors
:ref:`grid_bg`      std_logic_vector                   Grid background colors
=================== =================== ============== ===========================

.. _inputs:

inputs
~~~~~~

The number of channel inputs which scopeio is going to plot.

.. _input_preamp:

input_preamp
~~~~~~~~~~~~

This parameter is required to set the analog inputs when to have different scales. If all the inputs have the same voltage resolution, set it to
(0 to inputs-1 => 1.0)

.. _layout_id:

layout_id
~~~~~~~~~

layout_id selects one of the two display layouts. The table below shows the parameter's values to be seti, according to the resolution required.

===== ========== ===============
Value Resolution Video frequency
===== ========== ===============
    0  1920x1080         150 MHz
    1    800x600          40 MHz
===== ========== ===============

There is a nano-window system in which other layouts can be described pretty easily. So far, there are only two.

.. _vt_div:

vt_div
~~~~~~

It represents the vertical base division. The least five significant bits represent the binary point. The default value b"0_001_00000" means 1.00000.

.. _hz_div:

hz_div
~~~~~~

It represents the horizontal base division. The least five significant bits represent the binary point. The default value b"0_001_00000" means 1.00000.

.. _vt_scales:

vt_scales
~~~~~~~~~

:ref:`vt_scales` is sixteen-elements-long vector whose elements are :ref:`scale_t`
records. Each one describes one of the the sixteen vertical scales using
:ref:`vt_div` as a base to display the corresponding values on the screen. The
steps to set up each element of vt_scales are the following:
  
.. _hz_scales:

hz_scales
~~~~~~~~~

:ref:`hz_scales` is sixteen-elements-long vector whose elements are :ref:`scale_t`
records. Each one describes one of the the sixteen horizontal scales using
:ref:`hz_div` as a base to display the corresponding values on the screen. The
steps to set up each element of hz_scales are the followings:

.. image:: hzscale_vector.svg
   :target: images/hzscale_vector.svg
  
A
    Choose your sample rate: in the exmaple it is 800 KS/s
B
    Each division has 32 pixels, The base division is gotten by dividing 32 by
    the sample rate. In the example the result is 40 us as the sample rate is
    .8 MS/s 
C
    Set the record member :ref:`step` to 40.00. :ref:`step` only controls the increment of
    the horizontal axis' marks.
D
    Get the corresponding ascii code of factor character and set it to :ref:`deca`. In
    the example: the corresponding factor is micro.
E
    The :ref:`hz_div` parameter is composed of five fraction bits, three
    integer bits and one sign bit. Three integer bits mean that integer part
    of :ref:`hz_div` must be one digit only. The horizontal base division must be
    aligned according to that. 

    Following the example:
    The result of the horizontal base division is 40.00. To fit it in
    :ref:`hz_div`, the decimal point should be shifted one position to the left
    to get the one-digit-only integer part. The result, then, is 4.000, and
    the corresponding binary representation is 0_100_00000 in which the first
    '_' charater separates the sign bit and second one the fraction bits.  

F
    Once the correct value is selected for :ref:`hz_div`, the record member
    :ref:`scale` should be set according to the scale table, to display the correct
    horizontal base division value on the screen. The :ref:`scale` member is a four
    bit vector whose two left bits shift the decimal point while the other
    two bits on the right select a number from: 1.0, 2.5, 5.0 or 2.0 by which the
    :ref:`hz_div` is multiplied. The proper number is selected by combining all
    of the four bits.

H
    Set the record member :ref:`mult` according to by how much the
    :ref:`input_clk` should be devided. if the division is going to be made by
    multiplexing the input channel of ADCs set it to 1. Use
    :ref:`tdiv` to know which scale has been selected by the user.

.. _gauge_labels:

gauge_labels
~~~~~~~~~~~~

The labels that are going to be displayed describing the reading.

.. _unit_symbols:

unit_symbols
~~~~~~~~~~~~

Unit symbols that readings are about. One character per reading.

.. _channels_fg:

channels_fg
~~~~~~~~~~~

The colors which input channels are going to be plot

.. image:: channel_fg.svg
   :target: images/channel_fg.svg

.. _channels_bg:

channels_bg
~~~~~~~~~~~

The background colors to which readings are associated

.. image:: channel_bg.svg
   :target: images/channel_bg.svg

.. _hzaxis_fg:

hzaxis_fg
~~~~~~~~~

The foreground color which the horizontal axis is going to be plot

.. _hzaxis_bg:

hzaxis_bg
~~~~~~~~~

The background color with which the horizontal axis is going to be plot

.. _grid_fg:

grid_fg
~~~~~~~

The foreground color which the grid is going to be displayed

.. _grid_bg:

grid_bg
~~~~~~~

The background color which the grid is going to be displayed

port
----

=================== ==== ================ =============== ================================
port                Mode Type             Default         Description
=================== ==== ================ =============== ================================
:ref:`mii_rxc`      in   std_logic                        Ethernet PHY receive clock
:ref:`mii_rxdv`     in   std_logic                        Ethernet PHY receive data valid
:ref:`mii_rxd`      in   std_logic_vector                 Ethernet PHY receive data 
:ref:`tdiv`         out  std_logic_vector                 
:ref:`channel_ena`  in   std_logic_vector (others => '1') Channel output Enable
:ref:`input_clk`    in   std_logic                        Input Channel Clocks
:ref:`input_ena`    in   std_logic                        Input Channel Enable
:ref:`input_data`   in   std_logic_vector                 Input Channel Samples
:ref:`video_clk`    in   std_logic                        Video Clock
:ref:`video_rgb`    out  std_logic_vector                 Video Pixel RGB
:ref:`video_vsync`  out  std_logic                        Video Vertical Sync
:ref:`video_hsync`  out  std_logic                        Video Horizontal Sync
:ref:`video_blank`  out  std_logic                        Video Blank
:ref:`video_sync`   out  std_logic                        Video Sync
=================== ==== ================ =============== ================================

.. _mii_rxc:

mii_rxc
~~~~~~~

Ethernet phy receive clock

.. _mii_rxdv:

mii_rxdv
~~~~~~~~

Ethernet phy received data valid clock. Connect it to mii phy


.. _mii_rxd:

mii_rxd
~~~~~~~

Ethernet phy received data clock. Connect it direct to FPGA corresponding mii phy

.. _tdiv:

tdiv
~~~~

Ethernet phy received data clock. Connect it direct to FPGA corresponding mii phy


.. _channel_ena:

channel_ena
~~~~~~~~~~~


Enable the corresponing channel to be plotted


.. _input_clk:

input_clk
~~~~~~~~~

Input sample data clock

.. _input_ena:

input_ena
~~~~~~~~~

Enable input sample data

.. _input_data:

input_data
~~~~~~~~~~

Input sample data

.. image:: input_data.svg
   :target: images/input_data.svg

.. _video_clk:

video_clk
~~~~~~~~~

Video dot clock

.. _video_rgb:

video_rgb
~~~~~~~~~

Video output pixel

.. _video_vsync:

video_vsync
~~~~~~~~~~~

Vertical sync output

.. _video_hsync:

video_hsync
~~~~~~~~~~~

Horizontal sync output

.. _video_blank:

video_blank
~~~~~~~~~~~

Video blank

.. _video_sync:

video_sync
~~~~~~~~~~

Video sync signal
