DOMAIN := imrsv-schema-linter-db.localhost

all: $(DOMAIN).crt $(DOMAIN).key $(DOMAIN).dhparam

$(DOMAIN).key:
	@# Generate self-signed cert for development use.
	@openssl req -x509 \
	     -nodes \
	     -days 365 \
	     -newkey ed25519 \
	     -subj '/CN=imrsv-schema-linter-db.localhost' \
	     -addext 'subjectAltName = DNS:imrsv-schema-linter-db.localhost' \
	     -keyout ./'$(DOMAIN)'.key \
	     -out ./'$(DOMAIN)'.crt

$(DOMAIN).crt: $(DOMAIN).key

# SLOW!
# Questionable benefit. The main thing is to use curves ≥ 2048 bits, at least,
# as of this writing, and to check that in the linter. That and RFC curves
# built into OpenSSL (e.g., ffdhe…) if supported by PG.
$(DOMAIN).dhparam:
	@openssl dhparam -out '$@' 2048

clean:
	@rm -rf '$(DOMAIN).key' '$(DOMAIN).crt' '$(DOMAIN).dhparam'

.PHONY: clean
