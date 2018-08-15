PREFIX=
PROG = "make-function.sh"
install:
	@[ -z "$(PREFIX)" ] && echo "MUST SET PREFIX TO WHERE SCRIPT WILL BE INSTALLED" >&2 && exit 1 || true
	@[ -d $(PREFIX) ] && cp  ${PROG}  $(PREFIX) || echo "$(PREFIX) is not a folder or does not exist"
