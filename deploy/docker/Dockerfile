ARG GO_VERSION=1.26.0

############################
# Build stage
############################
FROM golang:${GO_VERSION}-alpine AS builder
WORKDIR /app

COPY . .

# Optional builder hook
RUN if [ -f /app/deploy/docker/extra-build-commands.sh ]; then \
      sh /app/deploy/docker/extra-build-commands.sh; \
    fi

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 GOFLAGS=-mod=vendor \
    go build -o /out/service cmd/main.go

############################
# Runtime stage
############################
FROM alpine:latest

RUN apk add --no-cache ca-certificates tzdata curl

# Copy runtime hook into image and run it
COPY deploy/docker/extra-commands.sh /extra-commands.sh
RUN sh /extra-commands.sh || true

COPY --from=builder /out/service /service
ENTRYPOINT ["/service"]