# Download installation script.
curl -O http://vestacp.com/pub/vst-install.sh
# Run it
bash vst-install.sh --nginx yes --apache yes --phpfpm no --named yes --remi yes --vsftpd no --proftpd yes --iptables no --fail2ban no --quota yes --exim yes --dovecot yes --spamassassin no --clamav no --softaculous no --mysql yes --postgresql no --email g_tmy@hotmail.com --password admin25

#Run Roundcube Installer
curl -O https://raw.githubusercontent.com/gtmylab/vcp/main/install_roundcube.sh
chmod +x install_roundcube.sh
./install_roundcube.sh
