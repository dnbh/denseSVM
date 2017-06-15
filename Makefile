.PHONY=all tests clean obj
CXX=g++
CC=gcc
STD=c++1z
WARNINGS=-Wall -Wextra -Wno-char-subscripts \
		 -Wpointer-arith -Wwrite-strings -Wdisabled-optimization \
		 -Wformat -Wcast-align -Wno-unused-function -Wno-unused-parameter
DBG:= -DNDEBUG
OPT:= -O3 -funroll-loops -pipe -fno-strict-aliasing -march=native -fopenmp
OS:=$(shell uname)
ifneq (,$(findstring g++,$(CXX)))
	ifeq ($(shell uname),Darwin)
		ifeq (,$(findstring clang,$(CXX)))
			FLAGS := $(FLAGS) -Wa,-q
			CLHASH_CHECKOUT := "&& git checkout mac"
		else
			FLAGS := $(FLAGS) -flto
			CLHASH_CHECKOUT := "&& git checkout master"
		endif
	endif
endif
OPT:=$(OPT) $(FLAGS)
FLOAT_TYPE=double
XXFLAGS=-fno-rtti
CXXFLAGS=$(OPT) $(XXFLAGS) -std=$(STD) $(WARNINGS) -DFLOAT_TYPE=$(FLOAT_TYPE)
CCFLAGS=$(OPT) -std=c11 $(WARNINGS)
LIB=-lz -pthread
LD=-L.

OBJS=$(patsubst %.cpp,%.o,$(wildcard lib/*.cpp))
TEST_OBJS=$(patsubst %.cpp,%.o,$(wildcard test/*.cpp))
EXEC_OBJS=$(patsubst %.cpp,%.o,$(wildcard src/*.cpp))

EX=$(patsubst src/%.o,%,$(EXEC_OBJS))

# If compiling with c++ < 17 and your compiler does not provide
# bessel functions with c++14, you must compile against boost.

INCLUDE=-I. -Ilib -Iblaze

ifdef BOOST_INCLUDE_PATH
INCLUDE += -I$(BOOST_INCLUDE_PATH)
endif

OBJS:=$(OBJS) klib/kstring.o

all: $(OBJS) $(EX) unit

obj: $(OBJS) $(EXEC_OBJS)

test/%.o: test/%.cpp
	$(CXX) $(CXXFLAGS) $(INCLUDE) $(LD) $(OBJS) -c $< -o $@ $(LIB)

klib/kstring.o:
	cd klib && make kstring.o && cd ..

%.o: %.cpp
	$(CXX) $(CXXFLAGS) $(DBG) $(INCLUDE) $(LD) -c $< -o $@ $(LIB)

%: src/%.o $(OBJS)
	$(CXX) $(CXXFLAGS) $(DBG) $(INCLUDE) $(LD) $(OBJS) $< -o $@ $(LIB)

%.o: %.c
	$(CC) $(CCFLAGS) -Wno-sign-compare $(DBG) $(INCLUDE) $(LD) -c $< -o $@ $(LIB)


tests: clean unit

unit: $(OBJS) $(TEST_OBJS)
	$(CXX) $(CXXFLAGS) $(INCLUDE) $(TEST_OBJS) $(LD) $(OBJS) -o $@ $(LIB)

clean:
	rm -f $(EXEC_OBJS) $(OBJS) $(EX) $(TEST_OBJS) unit lib/*o src/*o

mostlyclean: clean
