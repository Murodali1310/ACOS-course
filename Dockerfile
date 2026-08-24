FROM debian:bookworm-slim AS build

RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
        build-essential \
        ca-certificates \
        cmake \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
COPY ["Proxy Server/", "/src/"]

RUN cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
    && cmake --build build --parallel

FROM debian:bookworm-slim AS runtime

RUN groupadd --system proxyapp \
    && useradd --system --gid proxyapp --no-create-home proxyapp

COPY --from=build /src/build/server /usr/local/bin/proxy-server

USER proxyapp
EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/proxy-server"]
CMD ["8080"]
