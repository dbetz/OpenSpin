# cross compilation scheme taken from Eric Smith's spin2cpp compiler
# if CROSS is defined, we are building a cross compiler
# possible targets are: win32, rpi

ifeq ($(CROSS),win32)
  CC=i586-mingw32msvc-gcc
  CXX=i586-mingw32msvc-g++
  EXT=.exe
  BUILD=./build-win32
else ifeq ($(CROSS),rpi)
  CC=arm-linux-gnueabihf-gcc
  CXX=arm-linux-gnueabihf-g++
  EXT=
  BUILD=./build-rpi
else
  CC=gcc
  CXX=g++
  EXT=
  BUILD=./build
endif

OS:=$(shell uname)

ifeq ($(OS),Darwin)
	CFLAGS+=-Wall -g -Wno-self-assign
else
	CFLAGS+=-Wall -g -static
endif

CXXFLAGS += $(CFLAGS)

TARGET=$(BUILD)/openspin$(EXT)
SRCDIR=SpinSource
OBJ=$(BUILD)/openspin.o \
	$(BUILD)/flexbuf.o \
	$(BUILD)/preprocess.o \
	$(BUILD)/textconvert.o \
	$(BUILD)/pathentry.o \
	$(BUILD)/objectheap.o

LIBDIR=./PropellerCompiler
LIBNAME=$(LIBDIR)/$(BUILD)/libopenspin.a

all: $(BUILD) $(LIBNAME) $(OBJ) Makefile
	$(CXX) -o $(TARGET) $(CXXFLAGS) $(OBJ) $(LIBNAME)

$(BUILD)/%.o: $(SRCDIR)/%.cpp
	$(CXX) $(CXXFLAGS) -o $@ -c $<

$(LIBNAME):
	make -C $(LIBDIR) CROSS=$(CROSS) all

$(BUILD):
	mkdir -p $(BUILD)

clean:
	rm -rf $(BUILD)
	make -C $(LIBDIR) clean
