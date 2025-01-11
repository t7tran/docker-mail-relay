FROM alpine:3.21.2

ENV EXT_RELAY_HOST=email-smtp.us-east-1.amazonaws.com \
    EXT_RELAY_PORT=25 \
    RELAY_HOST_NAME=relay.example.com \
    ACCEPTED_NETWORKS='192.168.0.0/16 172.16.0.0/12 10.0.0.0/8' \
    USE_TLS=no \
    TLS_VERIFY=may \
    SERVER_CA_PATH=/etc/ssl/certs \
    SERVER_CA_FILE=/etc/ssl/certs/CAfile \
    SERVER_CERT_FILE=/etc/ssl/smtp.pem \
    SERVER_KEY_FILE=/etc/ssl/smtp.key \
    SERVER_SEC_LEVEL=may \
    SERVER_USE_TLS=no

# Add files
COPY ./rootfs /

# Packages: update
RUN apk --no-cache add postfix postfix-pcre ca-certificates libsasl cyrus-sasl supervisor rsyslog bash gomplate && \
    mkfifo /var/spool/postfix/public/pickup && \
    ln -s /etc/postfix/aliases /etc/aliases && \
    echo test1#2 | saslpasswd2 -c -p -n -u test.com test && \
    chown root:postfix /etc/sasl2/sasldb2 && \
    chmod g+r /etc/sasl2/sasldb2 && \
    chmod +x /root/run.sh && \
# install smtp-cli for testing
    apk --no-cache add perl \
                       perl-io-socket-ssl \
                       perl-digest-hmac \
                       perl-term-readkey \
                       perl-mime-lite \
                       perl-io-socket-inet6 \
                       perl-net-dns \
#                       perl-file-libmagic \
                       && \
    wget -O /usr/local/bin/smtp-cli https://raw.githubusercontent.com/mludvig/smtp-cli/v3.10/smtp-cli && \
# suppress warning of missing File::LibMagic module
    sed -i 's/missing_modules_ok = 0/missing_modules_ok = 1/' /usr/local/bin/smtp-cli && \
    chmod +x /usr/local/bin/smtp-cli && \
# clean up
    rm -rf /apk /tmp/* /var/cache/apk/*

# Declare
EXPOSE 25

CMD ["/root/run.sh"]
