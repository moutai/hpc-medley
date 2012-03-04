SHELL=/bin/sh
BENCHMARK=mf
BENCHMARKU=MF

include ../config/make.def


OBJS = mf.o

include ../sys/make.common

${PROGRAM}: config ${OBJS}
	${FLINK} ${FLINKFLAGS} -o ${PROGRAM} ${OBJS} ${F_LIB}

.f.o:
	${FCOMPILE} $<

mf.o:             mf.f npbparams.h

clean:
	- rm -f *.o *~ mputil*
	- rm -f npbparams.h core
