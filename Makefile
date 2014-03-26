include config.mk

BINS=sabr sabr-bootstrap sabr-query sabr-table
LIBS=defaults rel.awk

all: options
	@echo "To install, use 'make install'"

options:
	@echo sabr build options
	@echo "PREFIX  = ${PREFIX}"
	@echo "LIBDIR  = ${LIBDIR}"
	@echo "DATADIR = ${DATADIR}"

install: dirs ${BINS} ${LIBS}
	@echo "installed sabr"

dirs:
	@mkdir -p ${BINDIR}
	@mkdir -p ${LIBDIR}
	@mkdir -p ${DATADIR}/{tables,headers}
	@install -d ${BINDIR} ${DATADIR} ${LIBDIR}

${BINS}:
	@sed "s:LIBDIR:${LIBDIR}:g" < bin/${@} > ${BINDIR}/${@}
	@chmod 755 ${BINDIR}/${@}

${LIBS}:
	@sed -e "s/VERSION/${VERSION}/g" -e "s:DATADIR:${DATADIR}:g" < lib/${@} > ${LIBDIR}/${@}

uninstall:
	@rm -rf ${DOCDIR}
	@rm -rf ${LIBDIR}
	@rm -f ${BINDIR}/sabr ${BINDIR}sabr-bootstrap ${BINDIR}/sabr-query ${BINDIR}/sabr-table
	@echo "uninstalled sabr"
