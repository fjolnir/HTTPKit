CC = clang

PREFIX = /usr/local
PRODUCT_NAME = libhttpkit.so

CFLAGS  = -fblocks -fobjc-nonfragile-abi -fno-constant-cfstrings -I. -Wall -g -O0 -I/usr/local/include -Idependencies -DDEBUG_TRACE -Wno-trigraphs

LIB_CFLAGS = -fPIC
LDFLAGS=-L/usr/local/lib -lobjc -lpthread -ldispatch -lCoreFoundation -lfoundation_lite

SRC       = HTTPKit/HTTP.m \
            $(wildcard dependencies/CocoaOniguruma/*.m)

SRC_NOARC = HTTPKit/HTTPConnection.m \
            HTTPKit/NSBlockUtilities.m \
            dependencies/mongoose/mongoose.c \
            $(wildcard dependencies/CocoaOniguruma/oniguruma/*.c)

TEST_SRC  = demo/main.m

OBJ       = $(addprefix build/, $(patsubst %.c, %.o, $(SRC:.m=.o)))
OBJ_NOARC = $(addprefix build/, $(patsubst %.c, %.o, $(SRC_NOARC:.m=.o)))

$(OBJ): ARC_CFLAGS := -fobjc-arc

build/%.o: %.m
	@echo "\033[32m * Building $< -> $@\033[0m"
	@mkdir -p $(dir $@)
	@$(CC) $(CFLAGS) $(LIB_CFLAGS) $(ARC_CFLAGS) -c $< -o $@

build/%.o: %.c
	@echo "\033[32m * Building $< -> $@\033[0m"
	@mkdir -p $(dir $@)
	@$(CC) $(CFLAGS) $(LIB_CFLAGS) $(ARC_CFLAGS) -c $< -o $@


all: $(OBJ_NOARC) $(OBJ)
	@echo "\033[32m * Linking...\033[0m"
	@$(CC) $(LDFLAGS) $(OBJ) $(OBJ_NOARC) -shared -o build/$(PRODUCT_NAME)

install: all
	@mkdir -p $(PREFIX)/include/Foundation
	@cp Foundation/*.h $(PREFIX)/include/Foundation
	@cp build/$(PRODUCT_NAME) $(PREFIX)/lib/$(PRODUCT_NAME)

demo: all
	@$(CC) $(TEST_SRC) $(ARC_FLAGS) -L./build -lhttpkit -ldispatch -fobjc-arc -lobjc -fblocks $(CFLAGS) -o build/test
	@LD_LIBRARY_PATH=./build:/usr/local/lib build/test

clean:
	@rm -rf build
