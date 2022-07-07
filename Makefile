.PHONY: all clean aarch64 x86_64

all: x86_64-bin aarch64-bin aarch64-docker x86_64-docker

aarch64-bin:
	CARGO_TARGET_AARCH64_UNKNOWN_LINUX_MUSL_LINKER=aarch64-unknown-linux-musl-gcc cargo build --target aarch64-unknown-linux-musl --release
x86_64-bin:
	CARGO_TARGET_X86_64_UNKNOWN_LINUX_MUSL_LINKER=x86_64-unknown-linux-musl-gcc cargo build --target x86_64-unknown-linux-musl --release
aarch64-docker: aarch64-bin
	docker build -t keyswit-ch:arm64 -f Dockerfile.arm64 .
x86_64-docker: x86_64-bin
	docker build -t keyswit-ch:amd64 -f Dockerfile.amd64 .

clean:
	cargo clean