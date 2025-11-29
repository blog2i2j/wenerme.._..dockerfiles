ARG VERSION
ARG ALPINE_RELEASE

FROM gitea/act_runner:$VERSION AS builder

FROM wener/builder:${ALPINE_RELEASE}

RUN apk add --no-cache tini bash git tzdata
COPY --from=builder /usr/local/bin/act_runner /usr/local/bin/act_runner
COPY --from=builder /usr/local/bin/run.sh /usr/local/bin/run.sh

VOLUME /data

ENTRYPOINT ["/sbin/tini","--","run.sh"]
