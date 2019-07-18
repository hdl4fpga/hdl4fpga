entity scopeio
==============

.. figure:: scopeio.svg
   :target: images/scopeio.svg

   scopeio entity block diagram

Generic
-------

================ =================== ===========================
Parameter        Type                Description                
================ =================== ===========================
inputs           natural             Number of channel inputs   
vlayout_id       natural             Display layouts            
vt_unit          std_logic_vector    Vertical division unit     
hz_unit          std_logic_vector    Horizontal division unit   
vt_gain          std_logic_vector    Vertical gains             
hz_factor        std_logic_vector    Horizontal factors         
default_tracesfg std_logic_vector    Traces background colors  
default_gridfg   std_logic_vector    Grid foreground color 
default_gridbg   std_logic_vector    Grid background color 
default_hzfg     std_logic_vector    Horizontal foreground color 
default_hzbg     std_logic_vector    Horzontal background color 
default_vtfg     std_logic_vector    Vertical foreground color 
default_vtbg     std_logic_vector    Vertical background color 
default_textbg   std_logic_vector    Text background color 
default_sgmntbg  std_logic_vector    Segmanet background color 
default_bg       std_logic_vector    Screen background color 
================ =================== ===========================

Ports
-----

============ ==== ================ ================================
Port              Mode Type              Description
============ ==== ================ ================================
si_clk       in   std_logic        Serial input clock
si_frm       in   std_logic        Serial input frame
si_irdy      in   std_logic_vector Serial input initiatior ready 
si_data      in   std_logic_vector Serial input data 
so_clk       in   std_logic        Serial output clock
so_frm       in   std_logic        Serial output frame
so_irdy      in   std_logic_vector Serial output initiatior ready 
so_data      in   std_logic_vector Serial output data 
input_clk    in   std_logic        Input Channel Clocks
input_ena    in   std_logic        Input Channel Enable
input_data   in   std_logic_vector Input Channel Samples
video_clk    in   std_logic        Video Clock
video_pixel  out  std_logic_vector Video Pixel
video_vsync  out  std_logic        Video Vertical Sync
video_hsync  out  std_logic        Video Horizontal Sync
video_blank  out  std_logic        Video Blank
video_sync   out  std_logic        Video Sync
============ ==== ================ ================================

