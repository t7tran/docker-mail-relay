FROM alpine:3.7
MAINTAINER Uri Savelchev <alterrebe@gmail.com>

RUN apk --no-cache add postfix ca-certificates libsasl cyrus-sasl py-pip supervisor rsyslog && \
    pip install j2cli

# Add files
COPY ./rootfs /

RUN mkfifo /var/spool/postfix/public/pickup && \
    ln -s /etc/postfix/aliases /etc/aliases && \
    chmod +x /root/run.sh && \
    rm -rf /apk /tmp/* /var/cache/apk/*

# Declare
EXPOSE 25

CMD ["/root/run.sh"]
