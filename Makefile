.SUFFIXES: .o .cc .f90 .f03 .cpp .h .hpp  
FC = gfortran-4.7
LD  = gfortran-4.7

CC = g++-4.7
LCC = g++-4.7

AR = ar rv
RANLIB = ranlib
OPT_FLAGS = -m64 -std=c++11 -DNDEBUG -fopenmp -g -Wall -ansi -O3 -fomit-frame-pointer -fstrict-aliasing -ffast-math -msse2 -mfpmath=sse -march=native 

FOPT_FLAGS = -O3 -fopenmp 
#-fprefetch-loop-arrays -funroll-loops -ftree-loop-distribution -ffast-math -funroll-loops -finline-functions -ftree-vectorize -march=native -fno-signed-zeros -ffinite-math-only -fopenmp

LINKFLAGS = $(OPT_FLAGS)

FLINKFLAGS = $(FOPT_FLAGS)

LIBS = -lm -lgomp -L/usr/local/lib -lfftw3 -lfftw3_threads #-lfftw3_omp
INCLUDE	= -I../fftw++

PREFIX=/opt/fftma

.cpp.o:
	$(CC) $(OPT_FLAGS) $(INCLUDE) -o $*.o -c $*.cpp

.cc.o:
	$(CC) $(OPT_FLAGS) $(INCLUDE) -o $*.o -c $*.cc

.f03.o:
	$(FC) $(FOPT_FLAGS) -o $*.o -c $*.f03

.f90.o:
	$(FC) $(FOPT_FLAGS) -o $*.o -c $*.f90

include source.files
include target.mk

OBJECTS = $(CPPFILES:.cpp=.o) $(CCFILES:.cc=.o)

F90_FILES :=  $(filter %.f90, $(FORTRANFILES))
F03_FILES := $(filter %.f03, $(FORTRANFILES))

FOBJECTS = $(F90_FILES:.f90=.o) $(F03_FILES:.f03=.o) 

all:	$(FORTRAN)

$(FORTRANLIB): $(FOBJECTS)
	$(AR) $(FORTRANLIB) $(FOBJECTS)
	$(RANLIB) $(FORTRANLIB)

$(TARGET): $(OBJECTS)
	$(LCC) $(LINKFLAGS) $(INCLUDE) -o $(TARGET) $(OBJECTS) $(LIBS)

$(FORTRAN): $(FORTRANMAIN) $(FORTRANLIB)
	$(LD) $(FLINKFLAGS) -o $(FORTRAN) $(FORTRANMAIN) -L. -l$(FORTRANSHORTLIB) $(LIBS)
clean:
	rm -f $(TARGET) $(FORTRAN)
	rm -rf *.o *.mod *.so *.a

install: $(FORTRANLIB)
	mkdir -p $(PREFIX)/lib $(PREFIX)/include
	cp *.mod $(PREFIX)/include
	cp $(FORTRANLIB) $(PREFIX)/lib
