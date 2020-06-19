ScopeIO  
=======

It's tool to be embedded on a device that helps to understand what is happening inside
when simulation tools are not enough to guess what is wrong with the design.

How it was born
---------------

I found myself in a situation in which I had to debug a high-performance open
source portable DDR Core. I needed to capture a lot of data to know what was
happening and displayed it

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
