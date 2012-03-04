SHELL=/bin/sh
BENCHMARK=mg
BENCHMARKU=MG

include ../config/make.def

OBJS = mg.o ${COMMON}/print_results.o  \
        ${COMMON}/timers.o ${COMMON}/wtime.o ${COMMON}/names.o

include ../sys/make.common

${PROGRAM}: config ${OBJS}
	${FLINK} ${FLINKFLAGS} -o ${PROGRAM} ${OBJS} ${F_LIB}

mg.o:		mg.f npbparams.h
	${FCOMPILE} mg.f

clean:
	- rm -f *.o *~ 
	- rm -f npbparams.h core



