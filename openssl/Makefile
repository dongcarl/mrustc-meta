OPENSSL ?= openssl-1.1.0e

.PHONY: all clean

all: $(OPENSSL)/Makefile
	$(MAKE) -C $(OPENSSL)
	$(MAKE) -C $(OPENSSL) install

$(OPENSSL).tar.gz:
	curl -O "https://www.openssl.org/source/${OPENSSL}.tar.gz"

$(OPENSSL)/Makefile: $(OPENSSL).tar.gz
	tar xvf $<
	cd $(OPENSSL) && ./Configure --prefix="$(shell pwd)/out" linux-x86_64 -fPIC

clean:
	-rm $(OPENSSL).tar.gz
	-rm -r $(OPENSSL) out
  # ./Configure --prefix="$(pwd)/out" linux-x86_64 -fPIC

# [ -f "${OPENSSL}.tar.gz" ] || curl -O "https://www.openssl.org/source/${OPENSSL}.tar.gz"
# [ -d "${OPENSSL}" ] || tar xf "${OPENSSL}.tar.gz"
# read -p "Done downloading openssl, Press enter to continue"

# cd "${OPENSSL}"
# ./Configure --prefix="$(pwd)/out" linux-x86_64 -fPIC
# make --jobs="$(nproc)"
# make --jobs="$(nproc)" install
