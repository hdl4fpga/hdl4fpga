package std
===========

.. _scale_t:

scale_t
-------

=================== =================== ===========================
Parameter           Type                Description
=================== =================== ===========================
:ref:`from`         real                Scale's starting point
:ref:`step`         real                Scale's increment step
:ref:`mult`         natural             Adjusting input value
:ref:`scale`        std_logic_vector    Scale reading control
:ref:`deca`         std_logic_vector    Scale factor's ascii code
=================== =================== ===========================

.. _from:

from
~~~~

Scale starting point. It could be a positive as well as a negative number.

.. _step:

step
~~~~

Scale increment step. It could be a positive as well as a negative number.

.. _mult:

mult
~~~~

Adjusting input value. Mult is used to adjust the vertical input value to plot
the data according to the selected vertical axis' scale, and also to devide the
input data clk for the horizontal axis' scale.

.. _scale:

scale
~~~~~

Scale is a four bit std_logic_vector whose two most left bits shift the decimal
point of base divisions: :ref:`vt_div` or :ref:`hz_div` while the other two
most right bits select a number from: 1.0, 2.5, 5.0 or 2.0 by which those base
divisions are multiplied. The proper number is selected by combining all of the
four bits.

.. image:: scale.svg
   :target: images/scale.svg

.. _deca:

deca
~~~~

It is the corresponding ascii code to be displayed according to the scale factor.

.. _scale_vector:

scale_vector
------------

It is an unconstraint array vector of :ref:`scale_t`.

.. code-block:: vhdl

    type scale_vector is array (natural range <>) of scale_t;

