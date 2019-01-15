MRUSTC ?= mrustc
PREFIX ?= $(MRUSTC)/run_rustc/prefix

MRUSTCBIN = $(MRUSTC)/bin/mrustc

CARGOBIN = $(MRUSTC)/output/cargo
RUSTCBIN = $(MRUSTC)/output/rustc
THEGANG = $(CARGOBIN) $(RUSTCBIN)

RUSTCSRC = $(MRUSTC)/rustc-1.19.0-src/dl-version

PROC ?= $(shell nproc)

rustc/rustc.tar.gz: rustc/rustc-1.20.0-src/config.toml
	cd rustc/rustc-1.20.0-src/ && ./x.py build --stage 3
	tar -czf $@ -C rustc/rustc-1.20.0-src/build/x86_64-unknown-linux-gnu stage2

$(RUSTCSRC): $(MRUSTC)/Makefile
	$(MAKE) -C $(MRUSTC) RUSTCSRC

$(MRUSTC)/minicargo.mk $(MRUSTC)/tools/minicargo/Makefile: $(MRUSTC)/Makefile

$(MRUSTC)/Makefile:
	git clone https://github.com/thepowersgang/mrustc.git

$(MRUSTCBIN): $(MRUSTC)/Makefile
	$(MAKE) -C $(MRUSTC)

$(MRUSTC)/tools/bin/minicargo: $(MRUSTC)/tools/minicargo/Makefile
	$(MAKE) -C $(MRUSTC)/tools/minicargo

$(MRUSTC)/rustc-1.19.0-src/build/bin/llvm-config: $(MRUSTC)/minicargo.mk $(RUSTCSRC)
	$(MAKE) -C $(MRUSTC) -f minicargo.mk rustc-1.19.0-src/build/bin/llvm-config

LIBS: $(MRUSTC)/minicargo.mk $(RUSTCSRC)
	$(MAKE) -C $(MRUSTC) -f minicargo.mk PARLEVEL=9 LIBS

$(RUSTCBIN): $(MRUSTC)/minicargo.mk $(MRUSTCBIN) LIBS $(MRUSTC)/rustc-1.19.0-src/build/bin/llvm-config
	$(MAKE) -C $(MRUSTC) -f minicargo.mk output/rustc

$(CARGOBIN): $(MRUSTC)/minicargo.mk $(MRUSTCBIN) LIBS openssl/out/lib/libssl.a
	env OPENSSL_DIR="$(shell pwd)/openssl/out" $(MAKE) -C $(MRUSTC) -f minicargo.mk -j1 output/cargo

openssl/out/lib/libssl.a: openssl/Makefile
	$(MAKE) -C openssl

$(MRUSTC)/prefix/lib/rustlib/x86_64-unknown-linux-gnu/lib/libstd.rlib: $(RUSTCBIN) $(MRUSTC)/run_rustc/Makefile
	$(MAKE) -C $(MRUSTC)/run_rustc -j1

rustc/rustc-1.20.0-src.tar.gz:
	cd rustc && wget https://static.rust-lang.org/dist/rustc-1.20.0-src.tar.gz

rustc/rustc-1.20.0-src/config.toml: rustc/rustc-1.20.0-src.tar.gz rustc/config.toml $(MRUSTC)/prefix/lib/rustlib/x86_64-unknown-linux-gnu/lib/libstd.rlib
	tar -xvf $< -C rustc/
	sed -e 's~|CARGOBIN|~$(realpath $(MRUSTC))/run_rustc/prefix/bin/cargo~g' -e 's~|RUSTCBIN|~$(realpath $(MRUSTC))/run_rustc/prefix/bin/rustc~g' rustc/config.toml > $@

