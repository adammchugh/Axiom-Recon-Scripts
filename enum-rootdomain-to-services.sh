#!/bin/sh

wget https://raw.githubusercontent.com/adammchugh/Axiom-Recon-Scripts/development/ports.py -O ports.py
pip install python-libnmap

axiom-scan scope.txt -m subfinder -o subdomains.txt --threads 3

axiom-scan subdomains.txt -m dnsx -resp -o dns.txt

cat dns.txt | awk -F'[][]' '{print $2}' | anew ipaddrs.txt

#sort ipaddrs.txt | uniq -d > ipaddrs.txt

#axiom-scan ipaddrs.txt -m cf-check -o ipaddrs_filtered.txt

#axiom-scan ipaddrs_filtered.txt -m exclude-cdn -o ipaddrs_filtered.txt

axiom-scan ipaddrs.txt -m masscan -oX masscan.xml --top-ports 100 &

axiom-scan ipaddrs.txt -m nmap -oX nmap.xml -T4 --top-ports 100 -sV

python3 ports.py nmap.xml | anew hostnames.txt

axiom-scan hostnames.txt -m httpx -o http_hosts.txt

axiom-scan http_hosts.txt -m wpscan &

axiom-scan http_hosts.txt -m gobuster-dir -o http_hosts_dirbuster.txt &

axiom-scan http_hosts.txt -m gowitness -o screenshots &

axiom-scan http_hosts.txt -m ffuf -o content.csv --threads 2 &
