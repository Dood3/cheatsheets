## Allow non-root user to capture traffic:
```
sudo dpkg-reconfigure wireshark-common  
sudo usermod -a -G wireshark $USER  

=> logout & login
```
