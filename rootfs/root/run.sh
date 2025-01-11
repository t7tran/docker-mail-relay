#! /usr/bin/env bash
set -e # exit on error

# Variables
if [ -z "$SMTP_LOGIN" -o -z "$SMTP_PASSWORD" ] ; then
	echo "SMTP_LOGIN and SMTP_PASSWORD _must_ be defined"
	exit 1
fi

echo $RELAY_HOST_NAME > /etc/mailname

# Templates

compile() {
    if [[ -n "$1" ]]; then
		filePath=${1#*:}
		if [[ "$filePath" == *.template ]]; then
			gomplate -f "$filePath" > ${filePath%.template}
			filePath=${filePath%.template}
		fi
		[[ -f "${filePath}" && "$filePath" == *map ]] && postmap -o "${filePath}"
	fi
}

for f in $RECIPIENT_CANONICAL_MAPS $SENDER_BCC_MAPS $HEADER_CHECKS $SMTP_HEADER_CHECKS $CUSTOM_TRANSPORT_MAPS $BODY_CHECKS; do
    compile "$f"
done
for i in {1..10}; do
	var=CUSTOM_TRANSPORT_${i}_HEADER_CHECKS
    compile "${!var}"
done

gomplate -f /root/conf/postfix-main.cf > /etc/postfix/main.cf
gomplate -f /root/conf/postfix-master.cf > /etc/postfix/master.cf
gomplate -f /root/conf/sasl_passwd > /etc/postfix/sasl_passwd
postmap lmdb:/etc/postfix/sasl_passwd
# /etc/sasldb2
echo ${SMTPD_PASSWORD:-s0meP4s5} | saslpasswd2 -c -p -u ${RELAY_HOST_NAME} ${SMTPD_LOGIN:-sender}
postalias /etc/postfix/aliases

# Launch
rm -f /var/spool/postfix/pid/*.pid
exec /usr/bin/supervisord -n -c /etc/supervisord.conf
