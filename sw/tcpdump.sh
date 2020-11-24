sudo tcpdump -i ens37 -U -w - | tee dump.pcap | sudo tcpdump -X -r -
