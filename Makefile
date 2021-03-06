INSTALL_DIR=$(HOME)/.local/bin

LIBS=libpng libjpeg x11 xft xrender

CFLAGS=-Wall -Wextra -Wpedantic -std=c99 -pedantic -lm \
	   -Wshadow -Wpointer-arith -Wcast-qual \
	   -Wmissing-prototypes -Wold-style-definition -Wvla \
	   -Wdeclaration-after-statement \
	   $(shell for lib in $(LIBS); do pkg-config --cflags --libs $$lib; done) \
	   -D_POSIX_C_SOURCE=199309L -D_GNU_SOURCE

SRCS=main.c image.c fonts.c files.c window.c
OBJS=$(SRCS:.c=.o)
HDRS=common.h image.h fonts.h files.h window.h
EXE=sbimg

#
# Release variables
#
RELDIR=release
RELEXE=$(RELDIR)/$(EXE)
RELOBJS=$(addprefix $(RELDIR)/, $(OBJS))
RELCFLAGS=-Os -s -flto -march=native -mtune=native

#
# Debug variables
#
DBGDIR=debug
DBGEXE=$(DBGDIR)/$(EXE)
DBGOBJS=$(addprefix $(DBGDIR)/, $(OBJS))
DBGCFLAGS=-g -Og -DDEBUG

.PHONY: all
all: prep release debug

.PHONY: prep
prep:
	@mkdir -p $(DBGDIR) $(RELDIR)

#
# Debug rules
#
.PHONY: debug
debug: $(DBGEXE)

$(DBGEXE): $(DBGOBJS)
	$(CC) $(CFLAGS) $(DBGCFLAGS) $^ -o $(DBGEXE)

$(DBGDIR)/%.o: %.c $(HDRS)
	$(CC) -c $(CFLAGS) $(DBGCFLAGS) $< -o $@

#
# Release rules
#
.PHONY: release
release: $(RELEXE)

$(RELEXE): $(RELOBJS)
	$(CC) $(CFLAGS) $(RELCFLAGS) $^ -o $(RELEXE)

$(RELDIR)/%.o: %.c $(HDRS)
	$(CC) -c $(CFLAGS) $(RELCFLAGS) $< -o $@

.PHONY: clean
clean:
	rm $(RELEXE) $(RELOBJS) $(DBGEXE) $(DBGOBJS)

.PHONY: remake
remake: clean all

.PHONY: install
install: $(RELEXE)
	install $(RELEXE) $(INSTALL_DIR)/$(EXE)

.PHONY: uninstall
uninstall:
	rm $(INSTALL_DIR)/$(EXE)
