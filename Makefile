PREFIX = /usr/local/bin
IN     = absolutely-proprietary.sh
OUT    = absolutely-proprietary.sh

default: install

install:
	chmod +x "${IN}"
	cp "${IN}" "${PREFIX}/${OUT}"
