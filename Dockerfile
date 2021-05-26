# syntax=docker/dockerfile:1
# Build Stage
FROM golang:1.16 AS builder

ENV GOPATH=/root/go
ENV GOMODCACHE=/root/go/pkg/mod
ENV GOCACHE=/root/.cache/go-build
ENV GOENV=/root/.config/go/env

WORKDIR /root/go/src/github.com/KhaledEmaraDev/GoViolin/

COPY go.mod go.sum ./
RUN go get -d -v ./...

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .

# Run Stage
FROM alpine:latest  

RUN apk --no-cache add ca-certificates

WORKDIR /root/

COPY --from=builder /root/go/src/github.com/KhaledEmaraDev/GoViolin/app .

COPY templates/ ./templates/
COPY css/ ./css/
COPY img/ ./img/
COPY mp3/ ./mp3/

ENV PORT=7090
CMD ["./app"]
