# syntax=docker/dockerfile:1
FROM golang:1.22 AS builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o server .

FROM gcr.io/distroless/static:nonroot

COPY --from=builder /app/server /server
USER nonroot:nonroot

ENTRYPOINT ["/server"]
