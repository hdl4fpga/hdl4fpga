ScopeIO  
=======

What is it ?
------------

It is tool that can be embedded to measure what is happening inside of the FPGA
when simulation tools can't help to guess what is wrong.

How it was born
---------------

I found myself in a situation in which I had to debug a high-performance open
source portable DDR Core. I needed to capture a lot of data to know what was
happening.

Its goals are:

- Small footprint to be embedded it.
- Portability.
- Video interface to display data.
- Block RAM requirement only.
- Multiple communication system to dump and upload data 

TODO
~~~~

| [x] Add DDR core to capture high speed data.
| |x] Add data output stream.
