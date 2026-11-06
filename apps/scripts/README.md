# Application scripts

These scripts are intended to be run from the `apps` directory, where `bin/`
contains the compiled helper programs. Most scripts use the serial defaults
`TTY=/dev/ttyUSB0` and `SPEED=3000000`; set the corresponding environment
variables to override them.

Example:

```sh
cd apps
HOST=kit PKMODE=PKT ./scripts/siocomm.sh < request.bin > response.bin
```

## External dependencies

| Tool | Used by |
|---|---|
| `siosend`, `memtest`, `rqstdata`, `rgb8topixel`, `format`, `bundle`, `waveform` | compiled tools in `apps/bin` |
| `socat`, `xxd` | communication and conversion scripts |
| ImageMagick `convert`/`magick` | image conversion scripts |
| `stty` | `setuart.sh` |
| `nping` | `flood` |
| Gnuplot | `waveform.gp` |

The serial scripts also require access to the configured device and, where
applicable, permission to open the selected UDP or USB endpoint.

## Communication and device control

### `siocomm.sh`

Runs `bin/siosend` and selects the transport:

- `HOST=hostname` uses UDP and adds packet mode by default.
- `USBDEV=vendor:product.endpoint` uses USB and adds packet mode by default.
- Otherwise it configures `TTY` with `setuart.sh` and uses the serial device.

`PKMODE=PKT` forces packet mode; any other nonempty value selects stream mode.
`LOG=YES` enables logging. `DEVFD` selects the serial file descriptor.
Additional arguments are passed to `siosend`.

Examples:

```sh
HOST=kit ./scripts/siocomm.sh < packet.bin > response.bin
USBDEV=1234:abcd.01 PKMODE=PKT ./scripts/siocomm.sh < packet.bin > response.bin
TTY=/dev/ttyUSB1 SPEED=115200 ./scripts/siocomm.sh < packet.bin > response.bin
```

### `siocomm.bat`

Windows equivalent of `siocomm.sh`. It selects `host`, `usbdev`, or `tty`/
`speed`, then runs `bin/siosend.exe` in packet mode.

### `setuart.sh`

Configures the serial port named by `TTY` (default `/dev/ttyUSB0`) to `SPEED`
(default `3000000`), 8-bit raw mode, no parity, one stop bit. Fails if the
device is not a character device.

### `setaddr.sh [address]`

Sends a register/address command for `address` through `siocomm.sh`. The
address is formatted as six hexadecimal digits; `BADDR` can override it.

Example:

```sh
./scripts/setaddr.sh 0x120
```

### `dump.sh [address] [length]`

Reads memory starting at `address` (default `0`) for `length` bytes (default
`0`) and formats the returned register data. `TTY`, `SPEED`, `DEVFD`, and
transport variables are inherited by `siocomm.sh`.

### `sdump.sh [address]`

Convenience wrapper for `dump.sh`: selects `HOST=kit` and reads `0x3ff` bytes.

### `write.sh [address] [hex-data]`

Builds a write command containing the address and hexadecimal payload, sends it
through `siocomm.sh`, and prints the transmitted address/length and response.
The payload must contain only hexadecimal digits and must have an even number
of digits; invalid or missing payloads are rejected.

Example:

```sh
./scripts/write.sh 0x100 deadbeef
```

### `test.sh [host] [hex-data]`

Converts the hexadecimal second argument to binary and sends it with `socat` to
the UDP host in the first argument.

Example:

```sh
./scripts/test.sh kit 01020304
```

## Memory and image tools

### `memtest.sh [arguments...]`

Configures the serial port when no `HOST` is set, then runs `bin/memtest`.
With `HOST`, it runs the network form (`bin/memtest -h HOST`). `LOG=YES`
enables logging and `STDOUT=NO` suppresses normal output.

### `img2siofmt.sh`

Reads an image from standard input, resizes it to `WIDTH` pixels, converts it
to the selected pixel format, formats it into memory blocks, and bundles it for
SIO transfer.

Environment variables:

- `PIXEL` (default `rgb24`)
- `WIDTH` (default `800`)
- `BADDR` (default `0`)
- `BSIZE` (default `1280`)
- `PKTMD` (default `PKT`; selects `-p`)

Requires ImageMagick (`convert`) and `bin/rgb8topixel`, `bin/format`, and
`bin/bundle`.

Example:

```sh
PIXEL=rgb24 WIDTH=800 BADDR=0 BSIZE=1280 \
  ./scripts/img2siofmt.sh < image.png > image.sio
```

### `img2siofmt.bat`

Windows equivalent of `img2siofmt.sh`, using ImageMagick `magick` and the
Windows helper executables.

## Capture and plotting

### `udpdumpformat.sh`

Requests data with `bin/rqstdata`, receives it through `siosend -h kit -p`,
saves the binary stream as `data.bin`, and converts it with `bin/waveform` to
`data.txt`.

The generated files are written in the current directory and are overwritten
by later runs.

### `usbdumpformat.sh`

Same pipeline as `udpdumpformat.sh`, using USB device `1234:abcd.01` instead
of UDP.

### `waveform.gp`

Gnuplot configuration for `data.txt`. It plots columns 2–5 as four logic
signals, with a 0–250 microsecond x-axis tick interval and a `-10` to `15`
y-axis range.

## Traffic generation

### `flood`

Runs `nping` to send 10,000 ICMP packets to host `kit` at a rate of 1,000
packets per second.

This is intentionally a traffic generator; use it only on a network where
the test traffic is authorized.

## Protocol notes

When `siosend -p` is used, each input packet is preceded by a two-byte
little-endian payload length. The maximum payload is 8192 bytes. The SIO
transport adds register/ACK framing; the response stream emitted by
`siosend` is binary, not text.

## Troubleshooting

- `Serial port ... not found`: set `TTY` to the correct character device and
  check permissions.
- `Hostname ... not found`: verify `HOST` and DNS or `/etc/hosts`.
- No response: enable `LOG=YES`, verify the selected transport, and check that
  the target is listening on UDP port `57001`.
- Missing helper: build the required program in `apps/bin` before running the
  wrapper script.
- Image conversion failure: verify ImageMagick and that the input is supplied
  on standard input.

## Portability and safety

Several files use `/bin/sh` but contain shell features commonly associated
with Bash, including `==` tests and substring expansion. They work with the
project's usual shell environment but may need conversion to POSIX syntax for
other `/bin/sh` implementations.

`siocomm.sh` uses `eval` when constructing transport commands. Pass only
trusted environment variables and arguments; avoid using untrusted input as
`HOST`, `USBDEV`, `TTY`, or forwarded options.

The wrappers now use safe defaults when optional variables or positional
arguments are absent. Address and payload conversion scripts also validate
their hexadecimal inputs before sending data. All POSIX shell wrappers pass
`sh -n` syntax validation; external commands and device availability are
still checked only when the corresponding script is run.

