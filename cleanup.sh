sudo rm -f /var/cache/apt/*cache.bin
sudo apt-get --yes autoclean
sudo apt-get --yes clean
sudo find / -type f -name "*-old" |xargs sudo rm -rf
sudo rm -rf /var/backups/* /var/lib/apt/lists/* ~/.bash_history
find /var/log/ -type f |xargs sudo rm -rf
