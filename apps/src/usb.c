//                                                                            //
// Author(s):                                                                 //
//   Miguel Angel Sagreras                                                    //
//                                                                            //
// Copyright (C) 2015                                                         //
//    Miguel Angel Sagreras                                                   //
//                                                                            //
// This source file may be used and distributed without restriction provided  //
// that this copyright statement is not removed from the file and that any    //
// derivative work contains  the original copyright notice and the associated //
// disclaimer.                                                                //
//                                                                            //
// This source file is free software; you can redistribute it and/or modify   //
// it under the terms of the GNU General Public License as published by the   //
// Free Software Foundation, either version 3 of the License, or (at your     //
// option) any later version.                                                 //
//                                                                            //
// This source is distributed in the hope that it will be useful, but WITHOUT //
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or      //
// FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for   //
// more details at http://www.gnu.org/licenses/.                              //
//                                                                            //

#include <stdio.h>
#include <stdlib.h>
#include <libusb-1.0/libusb.h>

#define VENDOR_ID 0x1234
#define PRODUCT_ID 0xABCD
#define ENDPOINT_ADDRESS 0x01
#define TRANSFER_SIZE 64

int main() {
    libusb_device_handle *dev_handle;
    libusb_context *ctx = NULL;

    // Initialize libusb context
    if (libusb_init(&ctx) != 0) {
        printf("Error initializing libusb.\n");
        return 1;
    }

    // Open the USB device
    dev_handle = libusb_open_device_with_vid_pid(ctx, VENDOR_ID, PRODUCT_ID);
    if (dev_handle == NULL) {
        printf("Failed to open the USB device.\n");
        libusb_exit(ctx);
        return 1;
    }

    // Claim the interface of the USB device
    if (libusb_claim_interface(dev_handle, 0) != 0) {
        printf("Failed to claim the interface of the USB device.\n");
        libusb_close(dev_handle);
        libusb_exit(ctx);
        return 1;
    }

    // Buffer for the transfer
    unsigned char buffer[TRANSFER_SIZE] = "HELLO WORLD";

    // Perform the bulk transfer from the endpoint
    int transferred;
    int result = libusb_bulk_transfer(dev_handle, ENDPOINT_ADDRESS, buffer, TRANSFER_SIZE, &transferred, 0);
    if (result == 0) {
        if (ENDPOINT_ADDRESS & 0x80) {
            printf("Bulk transfer completed. Bytes transferred: %d\n", transferred);
        } else {
            printf("Bulk write transfer completed. Bytes transferred: %d\n", transferred);
        }
    } else {
        printf("Error in bulk transfer. Error code: %d\n", result);
    }

    // Release the interface and close the USB device
    libusb_release_interface(dev_handle, 0);
    libusb_close(dev_handle);
    libusb_exit(ctx);

    return 0;
}
