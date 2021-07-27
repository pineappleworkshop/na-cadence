FROM golang:1.15.7-alpine3.13 as build-env

RUN apk update \
    && apk upgrade \
    && apk add --no-cache ca-certificates openssl \
    && update-ca-certificates 2>/dev/null || true

RUN mkdir /na-cadence
WORKDIR /na-cadence
RUN apk add git
COPY go.mod .
COPY go.sum .
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -installsuffix cgo -o /go/bin/na-cadence

FROM scratch
COPY --from=build-env /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build-env /go/bin/na-cadence /go/bin/na-cadence
COPY --from=build-env /na-cadence/cadence /go/bin/cadence
ENTRYPOINT ["/go/bin/na-cadence"]
