CC=gcc
CPPC=g++
CFLAGS=-g -Og -Wall

.PHONY: fpga-prober crc32-checker clean

default: fpga-prober crc32-checker

fpga-prober: fpga-prober.cc
	@$(CPPC) $(CFLAGS) fpga-prober.cc -o fpga-prober.out
	@echo -e "\tCPPC fpga-prober.cc"

crc32-checker: crc32-checker.c
	@$(CC) $(CFLAGS) crc32-checker.c -o crc32-checker.out
	@echo -e "\tCC crc-checker.c"

clean:
	rm -rf fpga-prober.out crc32-checker.out
