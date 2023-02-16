FROM alpine:3.17
MAINTAINER Uri Savelchev <alterrebe@gmail.com>

# Add files
COPY ./rootfs /

# Packages: update
RUN apk --no-cache add postfix postfix-pcre ca-certificates libsasl cyrus-sasl py-pip supervisor rsyslog bash && \
    pip install j2cli && \
    mkfifo /var/spool/postfix/public/pickup && \
    ln -s /etc/postfix/aliases /etc/aliases && \
    echo test1#2 | saslpasswd2 -c -p -n -u test.com test && \
    chown root:postfix /etc/sasl2/sasldb2 && \
    chmod g+r /etc/sasl2/sasldb2 && \
    chmod +x /root/run.sh && \
    rm -rf /apk /tmp/* /var/cache/apk/*

# Declare
EXPOSE 25

CMD ["/root/run.sh"]
