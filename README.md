Postfix Mail Relay
======================

Contains:

* Postfix, running in a simple relay mode
* RSyslog

Processes are managed by supervisord, including cronjobs

The container provides a simple proxy relay for environments like Amazon VPC where you may have private servers with no Internet connection
and therefore with no access to external mail relays (e.g. Amazon SES, SendGrid and others). You need to supply the container with your 
external mail relay address and credentials. The configuration is tested with Amazon SES.


Exports
-------

* Postfix on `25`

Variables
---------

* `RELAY_HOST_NAME=relay.example.com`: A DNS name for this relay container (usually the same as the Docker's hostname)
* `ACCEPTED_NETWORKS=192.168.0.0/16 172.16.0.0/12 10.0.0.0/8`: A network (or a list of networks) to accept mail from
* `EXT_RELAY_HOST=email-smtp.us-east-1.amazonaws.com`: External relay DNS name
* `EXT_RELAY_PORT=25`: External relay TCP port
* `SMTP_LOGIN=`: Login to connect to the external relay (required, otherwise the container fails to start)
* `SMTP_PASSWORD=`: Password to connect to the external relay (required, otherwise the container fails to start)
* `USE_TLS=`: Remote require tls. Might be "yes" or "no". Default: no.
* `TLS_VERIFY=`: Trust level for checking the remote side cert. (none, may, encrypt, dane, dane-only, fingerprint, verify, secure). Default: may.

Example
-------

Launch Postfix container:

    $ docker run -d -h relay.example.com --name="mailrelay" -e SMTP_LOGIN=myLogin -e SMTP_PASSWORD=myPassword -p 25:25 ghcr.io/t7tran/mail-relay:2.1.0

Or using docker-compose

```
cd run-config
docker-compose up

# send a test email using custom transport 1
docker-compose exec relay smtp-cli --verbose \
    --disable-starttls \
    --user=client \
    --pass=p4ssword \
    --server=localhost:25 \
    --from testsender@example.com \
    --to admin@example.com \
    --subject "Test Custom Transport 1" \
    --body-plain "The email received must have [Custom1] prefix."

# send a test email using custom transport 2
docker-compose exec relay smtp-cli --verbose \
    --disable-starttls \
    --user=client \
    --pass=p4ssword \
    --server=localhost:25 \
    --from testsender@example.com \
    --to testreceiver@example.com \
    --subject "Test Custom Transport 2" \
    --body-plain "The email received must have [Custom2] prefix."

# send a test email using default transport
docker-compose exec relay smtp-cli --verbose \
    --disable-starttls \
    --user=client \
    --pass=p4ssword \
    --server=localhost:25 \
    --from testsender@standardmail.com \
    --to testreceiver@standardmail.com \
    --subject "Test Default Transport" \
    --body-plain "The email received must have no prefix."

# send a test email using default transport
docker-compose exec relay smtp-cli --verbose \
    --disable-starttls \
    --user=client \
    --pass=p4ssword \
    --server=localhost:25 \
    --from testsender@standardmail.com \
    --to testreceiver@standardmail.com \
    --subject "Test body_checks" \
    --body-plain /opt/body.txt

# check emails at http://localhost:8025

```