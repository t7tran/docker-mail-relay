FROM alpine:3.7
MAINTAINER Uri Savelchev <alterrebe@gmail.com>

# Add files
COPY ./rootfs /

# Packages: update
RUN apk --no-cache add postfix ca-certificates libsasl py-pip supervisor rsyslog && \
    pip install j2cli && \
    mkfifo /var/spool/postfix/public/pickup && \
    ln -s /etc/postfix/aliases /etc/aliases && \
    chmod +x /root/run.sh && \
    rm -rf /apk /tmp/* /var/cache/apk/*

# Declare
EXPOSE 25

CMD ["/root/run.sh"]
