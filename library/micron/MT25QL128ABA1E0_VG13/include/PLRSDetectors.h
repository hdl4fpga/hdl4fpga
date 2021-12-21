//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
//
//  Verilog Behavioral Model
//  Version 1.2
//
//  Copyright (c) 2013 Micron Inc.
//
//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
//
// This file and all files delivered herewith are Micron Confidential Information.
// 
// 
// Disclaimer of Warranty:
// -----------------------
// This software code and all associated documentation, comments
// or other information (collectively "Software") is provided 
// "AS IS" without warranty of any kind. MICRON TECHNOLOGY, INC. 
// ("MTI") EXPRESSLY DISCLAIMS ALL WARRANTIES EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO, NONINFRINGEMENT OF THIRD PARTY
// RIGHTS, AND ANY IMPLIED WARRANTIES OF MERCHANTABILITY OR FITNESS
// FOR ANY PARTICULAR PURPOSE. MTI DOES NOT WARRANT THAT THE
// SOFTWARE WILL MEET YOUR REQUIREMENTS, OR THAT THE OPERATION OF
// THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE. FURTHERMORE,
// MTI DOES NOT MAKE ANY REPRESENTATIONS REGARDING THE USE OR THE
// RESULTS OF THE USE OF THE SOFTWARE IN TERMS OF ITS CORRECTNESS,
// ACCURACY, RELIABILITY, OR OTHERWISE. THE ENTIRE RISK ARISING OUT
// OF USE OR PERFORMANCE OF THE SOFTWARE REMAINS WITH YOU. IN NO
// EVENT SHALL MTI, ITS AFFILIATED COMPANIES OR THEIR SUPPLIERS BE
// LIABLE FOR ANY DIRECT, INDIRECT, CONSEQUENTIAL, INCIDENTAL, OR
// SPECIAL DAMAGES (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS
// OF PROFITS, BUSINESS INTERRUPTION, OR LOSS OF INFORMATION)
// ARISING OUT OF YOUR USE OF OR INABILITY TO USE THE SOFTWARE,
// EVEN IF MTI HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
// Because some jurisdictions prohibit the exclusion or limitation
// of liability for consequential or incidental damages, the above
// limitation may not apply to you.
// 
// Copyright 2013 Micron Technology, Inc. All rights reserved.
//

reg byte3 = 1;
`ifdef N25Q256A33E
    // PLRS part1 detectors
    PLRSpart1Detect #(.count(PLRS_1st_x4_byte3 - 1),.protocol("quad"))      plrsQ3b(S, C, !prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x4_byte4 - 1),.protocol("quad"))      plrsQ4b(S, C,  prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x2_byte3 - 1),.protocol("dual"))     plrsD3b(S, C, !prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x2_byte4 - 1),.protocol("dual"))     plrsD4b(S, C,  prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x1_byte3 - 1),.protocol("extended")) plrsE3b(S, C, !prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x1_byte4 - 1),.protocol("extended")) plrsE4b(S, C,  prog.enable_4Byte_address);
    // PLRS part2 detector
    PLRSpart2Detect #(.count(PLRS_2nd - 1)) plrs2(S,C, busy);

`elsif  N25Q256A31E 
    // PLRS part1 detectors
    PLRSpart1Detect #(.count(PLRS_1st_x4_byte3 - 1),.protocol("quad"))      plrsQ3b(S, C, !prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x4_byte4 - 1),.protocol("quad"))      plrsQ4b(S, C,  prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x2_byte3 - 1),.protocol("dual"))     plrsD3b(S, C, !prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x2_byte4 - 1),.protocol("dual"))     plrsD4b(S, C,  prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x1_byte3 - 1),.protocol("extended")) plrsE3b(S, C, !prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x1_byte4 - 1),.protocol("extended")) plrsE4b(S, C,  prog.enable_4Byte_address);
    // PLRS part2 detector
    PLRSpart2Detect #(.count(PLRS_2nd - 1)) plrs2(S,C, busy);

`elsif  N25Q256A11E
    // PLRS part1 detectors
    PLRSpart1Detect #(.count(PLRS_1st_x4_byte3 - 1),.protocol("quad"))      plrsQ3b(S, C, !prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x4_byte4 - 1),.protocol("quad"))      plrsQ4b(S, C,  prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x2_byte3 - 1),.protocol("dual"))     plrsD3b(S, C, !prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x2_byte4 - 1),.protocol("dual"))     plrsD4b(S, C,  prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x1_byte3 - 1),.protocol("extended")) plrsE3b(S, C, !prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x1_byte4 - 1),.protocol("extended")) plrsE4b(S, C,  prog.enable_4Byte_address);
    // PLRS part2 detector
    PLRSpart2Detect #(.count(PLRS_2nd - 1)) plrs2(S,C, busy);

`elsif  N25Q256A13E
    // PLRS part1 detectors
    PLRSpart1Detect #(.count(PLRS_1st_x4_byte3 - 1),.protocol("quad"))      plrsQ3b(S, C, !prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x4_byte4 - 1),.protocol("quad"))      plrsQ4b(S, C,  prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x2_byte3 - 1),.protocol("dual"))     plrsD3b(S, C, !prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x2_byte4 - 1),.protocol("dual"))     plrsD4b(S, C,  prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x1_byte3 - 1),.protocol("extended")) plrsE3b(S, C, !prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x1_byte4 - 1),.protocol("extended")) plrsE4b(S, C,  prog.enable_4Byte_address);
    // PLRS part2 detector
    PLRSpart2Detect #(.count(PLRS_2nd - 1)) plrs2(S,C, busy);

`elsif N25Q128A11E
    // PLRS part1 detector
    PLRSpart1Detect #(.count(PLRS_1st_x4_byte3 - 1),.protocol("quad"))     plrsQ(S, C, byte3);
    PLRSpart1Detect #(.count(PLRS_1st_x2_byte3 - 1),.protocol("dual"))     plrsD(S, C, byte3);
    PLRSpart1Detect #(.count(PLRS_1st_x1_byte3 - 1),.protocol("extended")) plrsE(S, C, byte3);

    // PLRS part2 detector
    PLRSpart2Detect #(.count(PLRS_2nd - 1)) plrs2(S,C, busy);

`elsif N25Q128A13E
    // PLRS part1 detector
    PLRSpart1Detect #(.count(PLRS_1st_x4_byte3 - 1),.protocol("quad"))     plrsQ(S, C, byte3);
    PLRSpart1Detect #(.count(PLRS_1st_x2_byte3 - 1),.protocol("dual"))     plrsD(S, C, byte3);
    PLRSpart1Detect #(.count(PLRS_1st_x1_byte3 - 1),.protocol("extended")) plrsE(S, C, byte3);

    // PLRS part2 detector
    PLRSpart2Detect #(.count(PLRS_2nd - 1)) plrs2(S,C, busy);

`elsif N25Q128A11B
    // PLRS part1 detector
    PLRSpart1Detect #(.count(PLRS_1st_x4_byte3 - 1),.protocol("quad"))     plrsQ(S, C, byte3);
    PLRSpart1Detect #(.count(PLRS_1st_x2_byte3 - 1),.protocol("dual"))     plrsD(S, C, byte3);
    PLRSpart1Detect #(.count(PLRS_1st_x1_byte3 - 1),.protocol("extended")) plrsE(S, C, byte3);

    // PLRS part2 detector
    PLRSpart2Detect #(.count(PLRS_2nd - 1)) plrs2(S,C, busy);

`elsif N25Q128A13B
    // PLRS part1 detector
    PLRSpart1Detect #(.count(PLRS_1st_x4_byte3 - 1),.protocol("quad"))     plrsQ(S, C, byte3);
    PLRSpart1Detect #(.count(PLRS_1st_x2_byte3 - 1),.protocol("dual"))     plrsD(S, C, byte3);
    PLRSpart1Detect #(.count(PLRS_1st_x1_byte3 - 1),.protocol("extended")) plrsE(S, C, byte3);

    // PLRS part2 detector
    PLRSpart2Detect #(.count(PLRS_2nd - 1)) plrs2(S,C, busy);

//`elsif N25Q064A11E
//    // PLRS part1 detector
//    PLRSpart1Detect #(.count(PLRS_1st_x4_byte3 - 1),.protocol("quad"))     plrsQ(S, C, byte3);
//    PLRSpart1Detect #(.count(PLRS_1st_x2_byte3 - 1),.protocol("dual"))     plrsD(S, C, byte3);
//    PLRSpart1Detect #(.count(PLRS_1st_x1_byte3 - 1),.protocol("extended")) plrsE(S, C, byte3);
//
//    // PLRS part2 detector
//    PLRSpart2Detect #(.count(PLRS_2nd - 1)) plrs2(S,C, busy);
//
`elsif N25Q032A13E
    // PLRS part1 detector
    PLRSpart1Detect #(.count(PLRS_1st_x4_byte3 - 1),.protocol("quad"))     plrsQ(S, C, byte3);
    PLRSpart1Detect #(.count(PLRS_1st_x2_byte3 - 1),.protocol("dual"))     plrsD(S, C, byte3);
    PLRSpart1Detect #(.count(PLRS_1st_x1_byte3 - 1),.protocol("extended")) plrsE(S, C, byte3);

    // PLRS part2 detector
    PLRSpart2Detect #(.count(PLRS_2nd - 1)) plrs2(S,C, busy);

`elsif N25Q032A11E
    // PLRS part1 detector
    PLRSpart1Detect #(.count(PLRS_1st_x4_byte3 - 1),.protocol("quad"))     plrsQ(S, C, byte3);
    PLRSpart1Detect #(.count(PLRS_1st_x2_byte3 - 1),.protocol("dual"))     plrsD(S, C, byte3);
    PLRSpart1Detect #(.count(PLRS_1st_x1_byte3 - 1),.protocol("extended")) plrsE(S, C, byte3);

    // PLRS part2 detector
    PLRSpart2Detect #(.count(PLRS_2nd - 1)) plrs2(S,C, busy);

`elsif N25W032A13E
    // PLRS part1 detector
    PLRSpart1Detect #(.count(PLRS_1st_x4_byte3 - 1),.protocol("quad"))     plrsQ(S, C, byte3);
    PLRSpart1Detect #(.count(PLRS_1st_x2_byte3 - 1),.protocol("dual"))     plrsD(S, C, byte3);
    PLRSpart1Detect #(.count(PLRS_1st_x1_byte3 - 1),.protocol("extended")) plrsE(S, C, byte3);

    // PLRS part2 detector
    PLRSpart2Detect #(.count(PLRS_2nd - 1)) plrs2(S,C, busy);

`elsif N25W032A11E
    // PLRS part1 detector
    PLRSpart1Detect #(.count(PLRS_1st_x4_byte3 - 1),.protocol("quad"))     plrsQ(S, C, byte3);
    PLRSpart1Detect #(.count(PLRS_1st_x2_byte3 - 1),.protocol("dual"))     plrsD(S, C, byte3);
    PLRSpart1Detect #(.count(PLRS_1st_x1_byte3 - 1),.protocol("extended")) plrsE(S, C, byte3);

    // PLRS part2 detector
    PLRSpart2Detect #(.count(PLRS_2nd - 1)) plrs2(S,C, busy);

`elsif MT25QL512ABA1E0    
    // PLRS part1 detectors
    PLRSpart1Detect #(.count(PLRS_1st_x4_byte3 - 1),.protocol("quad"))      plrsQ3b(S, C, !prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x4_byte4 - 1),.protocol("quad"))      plrsQ4b(S, C,  prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x2_byte3 - 1),.protocol("dual"))     plrsD3b(S, C, !prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x2_byte4 - 1),.protocol("dual"))     plrsD4b(S, C,  prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x1_byte3 - 1),.protocol("extended")) plrsE3b(S, C, !prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x1_byte4 - 1),.protocol("extended")) plrsE4b(S, C,  prog.enable_4Byte_address);
    // PLRS part2 detector
    PLRSpart2Detect #(.count(PLRS_2nd - 1)) plrs2(S,C, busy);

`elsif MT25QL512ABA1F0    
    // PLRS part1 detectors
    PLRSpart1Detect #(.count(PLRS_1st_x4_byte3 - 1),.protocol("quad"))      plrsQ3b(S, C, !prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x4_byte4 - 1),.protocol("quad"))      plrsQ4b(S, C,  prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x2_byte3 - 1),.protocol("dual"))     plrsD3b(S, C, !prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x2_byte4 - 1),.protocol("dual"))     plrsD4b(S, C,  prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x1_byte3 - 1),.protocol("extended")) plrsE3b(S, C, !prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x1_byte4 - 1),.protocol("extended")) plrsE4b(S, C,  prog.enable_4Byte_address);
    // PLRS part2 detector
    PLRSpart2Detect #(.count(PLRS_2nd - 1)) plrs2(S,C, busy);

`elsif MT25QL512ABA8E0    
    // PLRS part1 detectors
    PLRSpart1Detect #(.count(PLRS_1st_x4_byte3 - 1),.protocol("quad"))      plrsQ3b(S, C, !prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x4_byte4 - 1),.protocol("quad"))      plrsQ4b(S, C,  prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x2_byte3 - 1),.protocol("dual"))     plrsD3b(S, C, !prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x2_byte4 - 1),.protocol("dual"))     plrsD4b(S, C,  prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x1_byte3 - 1),.protocol("extended")) plrsE3b(S, C, !prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x1_byte4 - 1),.protocol("extended")) plrsE4b(S, C,  prog.enable_4Byte_address);
    // PLRS part2 detector
    PLRSpart2Detect #(.count(PLRS_2nd - 1)) plrs2(S,C, busy);

`elsif MT25QL512ABA8F0    
    // PLRS part1 detectors
    PLRSpart1Detect #(.count(PLRS_1st_x4_byte3 - 1),.protocol("quad"))      plrsQ3b(S, C, !prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x4_byte4 - 1),.protocol("quad"))      plrsQ4b(S, C,  prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x2_byte3 - 1),.protocol("dual"))     plrsD3b(S, C, !prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x2_byte4 - 1),.protocol("dual"))     plrsD4b(S, C,  prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x1_byte3 - 1),.protocol("extended")) plrsE3b(S, C, !prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x1_byte4 - 1),.protocol("extended")) plrsE4b(S, C,  prog.enable_4Byte_address);
    // PLRS part2 detector
    PLRSpart2Detect #(.count(PLRS_2nd - 1)) plrs2(S,C, busy);

`elsif MT25QU512ABA1E0    
    // PLRS part1 detectors
    PLRSpart1Detect #(.count(PLRS_1st_x4_byte3 - 1),.protocol("quad"))      plrsQ3b(S, C, !prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x4_byte4 - 1),.protocol("quad"))      plrsQ4b(S, C,  prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x2_byte3 - 1),.protocol("dual"))     plrsD3b(S, C, !prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x2_byte4 - 1),.protocol("dual"))     plrsD4b(S, C,  prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x1_byte3 - 1),.protocol("extended")) plrsE3b(S, C, !prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x1_byte4 - 1),.protocol("extended")) plrsE4b(S, C,  prog.enable_4Byte_address);
    // PLRS part2 detector
    PLRSpart2Detect #(.count(PLRS_2nd - 1)) plrs2(S,C, busy);

`elsif MT25QU512ABA1F0    
    // PLRS part1 detectors
    PLRSpart1Detect #(.count(PLRS_1st_x4_byte3 - 1),.protocol("quad"))      plrsQ3b(S, C, !prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x4_byte4 - 1),.protocol("quad"))      plrsQ4b(S, C,  prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x2_byte3 - 1),.protocol("dual"))     plrsD3b(S, C, !prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x2_byte4 - 1),.protocol("dual"))     plrsD4b(S, C,  prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x1_byte3 - 1),.protocol("extended")) plrsE3b(S, C, !prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x1_byte4 - 1),.protocol("extended")) plrsE4b(S, C,  prog.enable_4Byte_address);
    // PLRS part2 detector
    PLRSpart2Detect #(.count(PLRS_2nd - 1)) plrs2(S,C, busy);

`elsif MT25QU512ABA8E0    
    // PLRS part1 detectors
    PLRSpart1Detect #(.count(PLRS_1st_x4_byte3 - 1),.protocol("quad"))      plrsQ3b(S, C, !prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x4_byte4 - 1),.protocol("quad"))      plrsQ4b(S, C,  prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x2_byte3 - 1),.protocol("dual"))     plrsD3b(S, C, !prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x2_byte4 - 1),.protocol("dual"))     plrsD4b(S, C,  prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x1_byte3 - 1),.protocol("extended")) plrsE3b(S, C, !prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x1_byte4 - 1),.protocol("extended")) plrsE4b(S, C,  prog.enable_4Byte_address);
    // PLRS part2 detector
    PLRSpart2Detect #(.count(PLRS_2nd - 1)) plrs2(S,C, busy);

`elsif MT25QU512ABA8F0    
    // PLRS part1 detectors
    PLRSpart1Detect #(.count(PLRS_1st_x4_byte3 - 1),.protocol("quad"))      plrsQ3b(S, C, !prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x4_byte4 - 1),.protocol("quad"))      plrsQ4b(S, C,  prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x2_byte3 - 1),.protocol("dual"))     plrsD3b(S, C, !prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x2_byte4 - 1),.protocol("dual"))     plrsD4b(S, C,  prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x1_byte3 - 1),.protocol("extended")) plrsE3b(S, C, !prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x1_byte4 - 1),.protocol("extended")) plrsE4b(S, C,  prog.enable_4Byte_address);
    // PLRS part2 detector
    PLRSpart2Detect #(.count(PLRS_2nd - 1)) plrs2(S,C, busy);

`elsif MT25QU128ABA8E0    
    // PLRS part1 detectors
    PLRSpart1Detect #(.count(PLRS_1st_x4_byte3 - 1),.protocol("quad"))      plrsQ3b(S, C, !prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x4_byte4 - 1),.protocol("quad"))      plrsQ4b(S, C,  prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x2_byte3 - 1),.protocol("dual"))     plrsD3b(S, C, !prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x2_byte4 - 1),.protocol("dual"))     plrsD4b(S, C,  prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x1_byte3 - 1),.protocol("extended")) plrsE3b(S, C, !prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x1_byte4 - 1),.protocol("extended")) plrsE4b(S, C,  prog.enable_4Byte_address);
    // PLRS part2 detector
    PLRSpart2Detect #(.count(PLRS_2nd - 1)) plrs2(S,C, busy);

`elsif MT25QL128ABA8E0    
    // PLRS part1 detectors
    PLRSpart1Detect #(.count(PLRS_1st_x4_byte3 - 1),.protocol("quad"))      plrsQ3b(S, C, !prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x4_byte4 - 1),.protocol("quad"))      plrsQ4b(S, C,  prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x2_byte3 - 1),.protocol("dual"))     plrsD3b(S, C, !prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x2_byte4 - 1),.protocol("dual"))     plrsD4b(S, C,  prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x1_byte3 - 1),.protocol("extended")) plrsE3b(S, C, !prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x1_byte4 - 1),.protocol("extended")) plrsE4b(S, C,  prog.enable_4Byte_address);
    // PLRS part2 detector
    PLRSpart2Detect #(.count(PLRS_2nd - 1)) plrs2(S,C, busy);

`elsif MT25QU256ABA8E0    
    // PLRS part1 detectors
    PLRSpart1Detect #(.count(PLRS_1st_x4_byte3 - 1),.protocol("quad"))      plrsQ3b(S, C, !prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x4_byte4 - 1),.protocol("quad"))      plrsQ4b(S, C,  prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x2_byte3 - 1),.protocol("dual"))     plrsD3b(S, C, !prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x2_byte4 - 1),.protocol("dual"))     plrsD4b(S, C,  prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x1_byte3 - 1),.protocol("extended")) plrsE3b(S, C, !prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x1_byte4 - 1),.protocol("extended")) plrsE4b(S, C,  prog.enable_4Byte_address);
    // PLRS part2 detector
    PLRSpart2Detect #(.count(PLRS_2nd - 1)) plrs2(S,C, busy);

`elsif MT25QL256ABA8E0    
    // PLRS part1 detectors
    PLRSpart1Detect #(.count(PLRS_1st_x4_byte3 - 1),.protocol("quad"))      plrsQ3b(S, C, !prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x4_byte4 - 1),.protocol("quad"))      plrsQ4b(S, C,  prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x2_byte3 - 1),.protocol("dual"))     plrsD3b(S, C, !prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x2_byte4 - 1),.protocol("dual"))     plrsD4b(S, C,  prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x1_byte3 - 1),.protocol("extended")) plrsE3b(S, C, !prog.enable_4Byte_address);
    PLRSpart1Detect #(.count(PLRS_1st_x1_byte4 - 1),.protocol("extended")) plrsE4b(S, C,  prog.enable_4Byte_address);
    // PLRS part2 detector
    PLRSpart2Detect #(.count(PLRS_2nd - 1)) plrs2(S,C, busy);

`endif
