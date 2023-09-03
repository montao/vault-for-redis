FROM hashicorp/vault

RUN apk add --no-cache jq
COPY entrypoint.sh                    /vault/entrypoint.sh
EXPOSE 8200
ENTRYPOINT [ "/vault/entrypoint.sh" ]

HEALTHCHECK \
    --start-period=5s \
    --interval=1s \
    --timeout=1s \
    --retries=30 \
        CMD [ "/bin/sh", "-c", "[ -f /tmp/healthy ]" ]
