#! /usr/bin/env ash
set -e # exit on error

# Variables
if [ -z "$SMTP_LOGIN" -o -z "$SMTP_PASSWORD" ] ; then
	echo "SMTP_LOGIN and SMTP_PASSWORD _must_ be defined"
	exit 1
fi
export SMTP_LOGIN SMTP_PASSWORD
export EXT_RELAY_HOST=${EXT_RELAY_HOST:-"email-smtp.us-east-1.amazonaws.com"}
export EXT_RELAY_PORT=${EXT_RELAY_PORT:-"25"}
export RELAY_HOST_NAME=${RELAY_HOST_NAME:-"relay.example.com"}
export ACCEPTED_NETWORKS=${ACCEPTED_NETWORKS:-"192.168.0.0/16 172.16.0.0/12 10.0.0.0/8"}
export USE_TLS=${USE_TLS:-"no"}
export TLS_VERIFY=${TLS_VERIFY:-"may"}

export SERVER_CA_PATH=${SERVER_CA_PATH:-"/etc/ssl/certs"}
export SERVER_CA_FILE=${SERVER_CA_FILE:-"/etc/ssl/certs/CAfile"}
export SERVER_CERT_FILE=${SERVER_CERT_FILE:-"/etc/ssl/smtp.pem"}
export SERVER_KEY_FILE=${SERVER_KEY_FILE:-"/etc/ssl/smtp.key"}
export SERVER_SEC_LEVEL=${SERVER_SEC_LEVEL:-"may"}
export SERVER_USE_TLS=${SERVER_USE_TLS:-"no"}

echo $RELAY_HOST_NAME > /etc/mailname

# Templates

for f in $RECIPIENT_CANONICAL_MAPS $SENDER_BCC_MAPS $SMTP_HEADER_CHECKS; do
	[[ -n "$f" && -f "${f#*:}" && "$f" == *map ]] && postmap "${f#*:}"
done

j2 /root/conf/postfix-main.cf > /etc/postfix/main.cf
j2 /root/conf/sasl_passwd > /etc/postfix/sasl_passwd
postmap /etc/postfix/sasl_passwd

# Launch
rm -f /var/spool/postfix/pid/*.pid
exec /usr/bin/supervisord -n -c /etc/supervisord.conf
