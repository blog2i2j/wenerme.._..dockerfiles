FROM wener/app

RUN apk add --no-cache asterisk openssl asterisk-{curl,dahdi,pgsql,sample-config,srtp}

RUN apk add --no-cache rsync

COPY 01-ssh.start /etc/local.d/

# HTTP HTTPS AMI
EXPOSE 8088 8089 5038
# SIP signaling RTP audio
EXPOSE 5060-5070/udp 8766-35000/udp
# IAX2
EXPOSE 4568 4568/udp
