FROM --platform=$BUILDPLATFORM rust:1-bullseye as build
ARG TARGETARCH

RUN case $TARGETARCH in \
        amd64) \
            dpkg --add-architecture amd64; \
            ;; \
        arm64) \
            dpkg --add-architecture arm64; \
            ;; \
        *) \
            echo "Unknown target architecture: $TARGETARCH" \
            exit 1 \
            ;; \
    esac

RUN apt -y update

RUN case $TARGETARCH in \
        amd64) \
            apt -y install \
                crossbuild-essential-amd64 \
                gcc-10-multilib-x86-64-linux-gnu \
                libc6-dev-i386-amd64-cross \
                libpq-dev:amd64 \
                libpq5:amd64 \
                libzstd-dev:amd64; \
            rustup target add x86_64-unknown-linux-gnu; \
            ;; \
        arm64) \
            apt -y install \
                crossbuild-essential-arm64 \
                gcc-10-aarch64-linux-gnu \
                libc6-dev-arm64-cross \
                libpq-dev:arm64 \
                libpq5:arm64 \
                libzstd-dev:arm64; \
            rustup target add aarch64-unknown-linux-gnu; \
            ;; \
        *) \
            echo "Unknown target architecture: ${TARGETARCH}" \
            exit 1 \
            ;; \
    esac

COPY . /src
WORKDIR /src 

ENV CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER=aarch64-linux-gnu-gcc-10
ENV CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER=x86_64-linux-gnu-gcc-10

RUN case $TARGETARCH in \
        amd64) \
            cargo build --release --target x86_64-unknown-linux-gnu; \
            mv ./target/x86_64-unknown-linux-gnu/release/keyswit-ch ./target/; \
            ;; \
        arm64) \
            cargo build --release --target aarch64-unknown-linux-gnu; \
            mv ./target/aarch64-unknown-linux-gnu/release/keyswit-ch ./target/; \
            ;; \
        *) \
            exit 1 \
            ;; \
    esac

FROM debian:bullseye-slim

COPY --from=build /src/target/keyswit-ch /usr/bin/keyswit-ch

EXPOSE 8080

RUN /usr/bin/keyswit-ch
