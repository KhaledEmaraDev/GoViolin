# syntax=docker/dockerfile:1
# Build Stage
# In Semantic Versioning major versions introduce breaking changes; so, avoid allowing
# docker to pull newer images by explicitly specifying <major>.<minor> version.
FROM golang:1.16 AS builder

# Change $GOPATH to avoid permission errors; although, we run as root, so it shouldn't
# matter.
ENV GOPATH=/root/go
ENV GOMODCACHE=/root/go/pkg/mod
ENV GOCACHE=/root/.cache/go-build
ENV GOENV=/root/.config/go/env

WORKDIR /root/go/src/github.com/KhaledEmaraDev/GoViolin/

# Pull golang app dependencies.
COPY go.mod go.sum ./
RUN go get -d -v ./...

# Compile golang for Linux to run on Alpine.
# Copy everything, because this stage will be used in testing.
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .

# Run Stage
# This is a multi-stage Dockerfile. This stage uses alpine for its minimal space usage.
# This step only copies the compiled binary from the build stage and the media from the
# source code.
FROM alpine:latest  

RUN apk --no-cache add ca-certificates

WORKDIR /root/

# Copy app binary from the build stage.
COPY --from=builder /root/go/src/github.com/KhaledEmaraDev/GoViolin/app .

# Copy media resoures from source code.
COPY templates/ ./templates/
COPY css/ ./css/
COPY img/ ./img/
COPY mp3/ ./mp3/

# Run on port 7090.
ENV PORT=7090
CMD ["./app"]
