package std
===========

.. comment: .. raw:: html
    <object with="80" data="input_data.svg" type="image/svg+xml"></object>

.. image:: scopeio.svg
   :target: images/scopeio.svg

scale_vector
------------

=================== =================== ===========================
Parameter           Type                Description
=================== =================== ===========================
:ref:`from`         natural             Scale starting point
:ref:`step`         real_vector         Increment of the scale
:ref:`mult`         natural             Adjusting input value
:ref:`scale`        std_logic_vector    Scale reading control
:ref:`deca`         std_logic_vector    Scale factor
=================== =================== ===========================

.. _from:

from
~~~~

The number of channel inputs which scopeio is going to plot.

.. _step:

step
~~~~

This parameter is required to set the analog inputs when to have different
scales. If all the inputs have the same voltage resolution, set it to (0 to
inputs-1 => 1.0)

.. _mult:

mult
~~~~

layout_id selects one of the two display layouts. The table below shows the
parameter's values to be seti, according to the resolution required.

.. _scale:

scale
~~~~~

It represents the vertical base division. The least five significant bits
represent the binary point. The default value b"0_001_00000" means 1.00000.

.. _deca:

deca
~~~~

It represents the horizontal base division. The least five significant bits
represent the binary point. The default value b"0_001_00000" means 1.00000.

