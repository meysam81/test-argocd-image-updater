FROM golang:1.24 AS build

WORKDIR /app

ENV CGO_ENABLED=0

RUN --mount=type=bind,source=go.mod,target=/app/go.mod \
    --mount=type=bind,source=go.sum,target=/app/go.sum \
    --mount=type=cache,target=/go/pkg/mod \
    go mod download

COPY . .

RUN --mount=type=cache,target=/go/pkg/mod \
    go build -o test-argocd-image-updater .

FROM scratch AS final

ENV GIN_MODE=release

COPY --from=build /app/test-argocd-image-updater /test-argocd-image-updater

CMD ["/test-argocd-image-updater"]
