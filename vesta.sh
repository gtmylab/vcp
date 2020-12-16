# Download installation script
curl -O http://vestacp.com/pub/vst-install.sh
# Run it
bash vst-install.sh --nginx no --apache yes --phpfpm no --named yes --remi yes --vsftpd no --proftpd yes --iptables no --fail2ban no --quota yes --exim yes --dovecot yes --spamassassin no --clamav no --softaculous yes --mysql yes --postgresql no --password admin25


#Run PHP Modified
curl -O https://raw.githubusercontent.com/gtmylab/vcp/main/vesta-php.sh
bash vesta-php.sh php56
