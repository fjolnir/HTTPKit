CC = clang

PREFIX  = /usr/local
PRODUCT = libhttpkit

CFLAGS  = -fblocks -fobjc-nonfragile-abi -fno-constant-cfstrings -Iinclude -Wall -g -O0 -I/usr/local/include -Idependencies -DDEBUG_TRACE -Wno-trigraphs -Wno-shorten-64-to-32

LIB_CFLAGS = -fPIC
LDFLAGS = -L/usr/local/lib -lobjc -lcrypto -lssl

SRC       = source/HTTP.m \
            $(wildcard dependencies/CocoaOniguruma/*.m)

SRC_NOARC = source/HTTPConnection.m \
            source/HTTPWebSocketConnection.m \
            source/NSBlockUtilities.m \
            dependencies/mongoose/mongoose.c \
            $(wildcard dependencies/CocoaOniguruma/oniguruma/*.c)

TEST_SRC  = demo/main.m

OBJ       = $(addprefix build/, $(patsubst %.c, %.o, $(SRC:.m=.o)))
OBJ_NOARC = $(addprefix build/, $(patsubst %.c, %.o, $(SRC_NOARC:.m=.o)))

$(OBJ): ARC_CFLAGS := -fobjc-arc

ifeq ($(shell uname),Darwin)
    PRODUCT_FILENAME += $(addsuffix .dylib,$(PRODUCT))
	LDFLAGS += -framework Foundation
else
    PRODUCT_FILENAME += $(addsuffix .so,$PRODUCT)
    LDFLAGS += `gnustep-config --base-libs` -ldispatch -lpthread
endif

build/%.o: %.m $(HEADERS)
	@echo "\033[32m * Building $< -> $@\033[0m"
	@mkdir -p $(dir $@)
	@$(CC) $(CFLAGS) $(LIB_CFLAGS) $(ARC_CFLAGS) -c $< -o $@

build/%.o: %.c $(HEADERS)
	@echo "\033[32m * Building $< -> $@\033[0m"
	@mkdir -p $(dir $@)
	@$(CC) $(CFLAGS) $(LIB_CFLAGS) $(ARC_CFLAGS) -c $< -o $@


all: $(OBJ_NOARC) $(OBJ)
	@echo "\033[32m * Linking...\033[0m"
	@$(CC) $(LDFLAGS) $(OBJ) $(OBJ_NOARC) -shared -o build/$(PRODUCT_FILENAME)

install: all
	@mkdir -p $(PREFIX)/include/HTTPKit
	@cp -r build/include/* $(PREFIX)/include/
	@cp build/$(PRODUCT_FILENAME) $(PREFIX)/lib/$(PRODUCT_NAME)

demo: all
	@$(CC) $(TEST_SRC) $(ARC_FLAGS) -L./build -lhttpkit -fobjc-arc -lobjc -fblocks $(CFLAGS) $(LDFLAGS) -o build/test
	@LD_LIBRARY_PATH=./build:/usr/local/lib build/test

clean:
	@rm -rf build
