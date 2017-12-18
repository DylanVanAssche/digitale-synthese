# DSSS Wireless Transmit-Receive System
This repository contains the VHDL files for the course "Digital Synthese: practica" by Jan Meel (KU Leuven, Campus De Nayer).

## Files
- Total (top file)

- Transmitter (top file)
	- access layer: PNGenerator, MUX
	- datalink layer: SequenceController, DataRegister
	- application layer: EdgeDetector, UpDownCounter, Debouncer, SegDecoder 

- Receiver (top file)
	- access layer: SegDecoder, DataLatch
	- datalink layer: DataShiftReg
	- application layer: DPLL, MatchedFilter, Correlator, Despreader, MUX, PNGenerator, Edgedetector

- Hardware UCF (Xilinx FPGA file)
	- transmitter
	- receiver

## License
Everything in this repository is available under the GPLv3 License.

