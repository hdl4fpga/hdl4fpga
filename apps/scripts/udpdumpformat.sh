#!/bin/sh
./bin/rqstdata |./bin/siosend -h kit -p|tee data.bin|./bin/waveform > data.txt 