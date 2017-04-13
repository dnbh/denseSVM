.PHONY=all tests clean obj
CXX=g++
CC=gcc
WARNINGS=-Wall -Wextra -Wno-char-subscripts \
         -Wpointer-arith -Wwrite-strings -Wdisabled-optimization \
         -Wformat -Wcast-align -Wno-unused-function -Wno-unused-parameter
DBG:= -DNDEBUG # -D_GLIBCXX_DEBUG -DNDEBUG # -fno-inline
OPT:= -O3 -funroll-loops \
      -pipe -fno-strict-aliasing -march=native -fopenmp
OS:=$(shell uname)
ifeq ($(OS),Darwin)
	OPT := $(OPT) -Wa,-q
else
    OPT := $(OPT) -flto
endif
XXFLAGS=-fno-rtti
CXXFLAGS=$(OPT) $(XXFLAGS) -std=c++17 $(WARNINGS)
CCFLAGS=$(OPT) -std=c11 $(WARNINGS)
LIB=-lz -pthread
LD=-L.

OBJS=$(patsubst %.cpp,%.o,$(wildcard lib/*.cpp)) klib/kstring.o
TEST_OBJS=$(patsubst %.cpp,%.o,$(wildcard test/*.cpp))
EXEC_OBJS=$(patsubst %.cpp,%.o,$(wildcard src/*.cpp))

EX=$(patsubst src/%.o,%,$(EXEC_OBJS))

HEADERS=lib/problem.h lib/misc.h

BOOST_INCLUDE_PATH = /cm/shared/apps/boost/1.60.0/include/
BOOST_LIB_PATH     = /cm/shared/apps/boost/1.60.0/lib

INCLUDE=-I. -Ilib -Iblaze

ifdef BOOST_INCLUDE_PATH
INCLUDE+= -I$(BOOST_INCLUDE_PATH)
LIB+= # -lboost_math_tr1
LD+= -L$(BOOST_LIB_PATH)
endif

all: $(OBJS) $(EX) unit

obj: $(OBJS) $(EXEC_OBJS)

test/%.o: test/%.cpp
	$(CXX) $(CXXFLAGS) $(INCLUDE) $(LD) -c $< -o $@ $(LIB)

%.o: %.cpp
	$(CXX) $(CXXFLAGS) $(DBG) $(INCLUDE) $(LD) -c $< -o $@ $(LIB)

%: src/%.o $(OBJS)
	$(CXX) $(CXXFLAGS) $(DBG) $(INCLUDE) $(LD) $(OBJS) $< -o $@ $(LIB)

%.o: %.c
	$(CC) $(CCFLAGS) $(DBG) $(INCLUDE) $(LD) -c $< -o $@ $(LIB)


tests: clean unit

unit: $(OBJS) $(TEST_OBJS) 
	$(CXX) $(CXXFLAGS) $(INCLUDE) $(TEST_OBJS) $(LD) $(OBJS) -o $@ $(LIB)


clean:
	rm -f $(EXEC_OBJS) $(OBJS) $(EX) $(TEST_OBJS) unit lib/*o src/*o

mostlyclean: clean
