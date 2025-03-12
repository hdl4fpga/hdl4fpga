#!/bin/sh
./bin/rqstdata |./bin/siosend -u 1234:abcd.01 -p|tee data.bin|./bin/waveform > data.txt 