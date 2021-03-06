CFLAGS = -g -O2 -Wall -Wextra -Isrc -DNDEBUG $(OPT-FLAGS)
LIBS = -ldl $(OPTLIBS)
PREFIX?=/usr/local

SOURCES=$(wildcard src/**/*.c src/*.c)
OBJECTS=$(patsubst %.c, %.o, $(SOURCES))

TEST_SRC=$(wildcard tests/*_tests.c)
TESTS=$(patsubst %.c, %, $(TEST_SRC))

TARGET=build/liblcthw.a
SO_TARGET=$(patsubst %.a,%.so,$(TARGET))

# The target build
all: clean\
	$(TARGET) $(SO_TARGET) tests

dev: CFLAGS=-g -Wall -Isrc -Wall -Wextra $(OPTFLAGS)

dev: all

$(TARGET): CFLAGS += -fPIC

$(TARGET): build $(OBJECTS)
	ar rcs $@ $(OBJECTS)
	ranlib $@

$(SO_TARGET): $(TARGET) $(OBJECTS)
	$(CC) -shared -o $@ $(OBJECTS)

build:
	@mkdir -p build
	@mkdir -p bin

# The Unit tests
.PHONY: tests

tests: CFLAGS += $(TARGET)

tests: $(TESTS)
	sh ./tests/runtests.sh

clean:
	rm -rf build $(OBJECTS) $(TESTS)
	rm -f tests/tests.log
	find . -name "*.gc*" -exec rm {} \;
	find . -name "*.o*" -exec rm {} \;
	rm -rf `find . -name "*.dSYM" -print`

# The Install
install: all
	install -d $(DESTDIR)/$(PREFIX)/lib
	install $(TARGET) $(DESTDIR)/$(PREFIX)/lib

# The checker
check:
	@echo Files with potential dangerous functions.
	@egrep '[^_.>a-zA-Z0-9](str(n?cpy|n?cat|xfrm|n?dup|str|pbrk|tok|_)|stpn?cpy|a?sn?printf|byte_)' $(SOURCES) || true

