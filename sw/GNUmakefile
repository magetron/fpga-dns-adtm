CC=gcc
CPPC=g++
CFLAGS=-g -Og -Wall
CRCFOLDER=eth-crc32-checker
PROBERFOLDER=fpga-prober

.PHONY: fpga-prober crc32-checker clean

default: fpga-prober crc32-checker

fpga-prober: $(PROBERFOLDER)/fpga-prober.cc
	@$(CPPC) $(CFLAGS) $(PROBERFOLDER)/fpga-prober.cc -o fpga-prober.out
	@echo -e "\tCPPC ${PROBERFOLDER}/fpga-prober.cc"

crc32-checker: $(CRCFOLDER)/crc32-checker.c
	@$(CC) $(CFLAGS) $(CRCFOLDER)/crc32-checker.c -o crc32-checker.out
	@echo -e "\tCC ${CRCFOLDER}/crc-checker.c"

clean:
	rm -rf fpga-prober.out crc32-checker.out
