# syntax=docker/dockerfile:1
# Build Stage
FROM golang:1.16 AS builder

WORKDIR /go/src/github.com/KhaledEmaraDev/GoViolin/

COPY go.mod go.sum ./
RUN go get -d -v ./...

COPY main.go home.go scale.go duet.go ./
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .

# Run Stage
FROM alpine:latest  

RUN apk --no-cache add ca-certificates

WORKDIR /root/

COPY --from=builder /go/src/github.com/KhaledEmaraDev/GoViolin/app .

COPY templates/ ./templates/
COPY css/ ./css/
COPY img/ ./img/
COPY mp3/ ./mp3/

ENV PORT=7090
CMD ["./app"]
