datarootdir="./share"
fontsdatadir="${datarootdir}/font"
AM_CFLAGS = -I/opt/onyx/mwo/include/directfb -I/opt/onyx/mwo/include -D_GNU_SOURCE
AM_CPPFLAGS = \
	-DDATADIR=\"${datarootdir}/directfb-examples\" \
	-DFONT=\"$(fontsdatadir)/decker.ttf\"

all: dfbinfo dfb_simple df_andi
dfbinfo:
	${CC} ${CFLAGS} ${LDFLAGS} $@.c -o ${BUILD_DIR}/$@
dfb_simple:
	${CC} ${CFLAGS} ${AM_CFLAGS} ${AM_CPPFLAGS} ${LDFLAGS} $@.c -o ${BUILD_DIR}/$@
df_andi:
	${CC} ${CFLAGS} ${AM_CFLAGS} ${AM_CPPFLAGS} ${LDFLAGS} $@.c -o ${BUILD_DIR}/$@
