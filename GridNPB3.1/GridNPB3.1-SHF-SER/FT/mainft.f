c-------------------------------------------------------------------------c
c                                                                         c
c                          G R I D   N P B   3.1                          c
c                                                                         c
c                  N  A  S   G R I D   B E N C H M A R K S                c
c                                                                         c
c                   F 7 7 / S E R I A L    V E R S I O N                  c
c                                                                         c
c                                F T                                      c
c                                                                         c
c-------------------------------------------------------------------------c
c                                                                         c
c    FT solves a (slightly modified) version of the NAS Parallel          c
c    Benchmarks FT code.                                                  c
c                                                                         c
c    Permission to use, copy, distribute and modify this software         c
c    for any purpose with or without fee is hereby granted.  We           c
c    request, however, that all derived work reference the NAS            c
c    Grid Benchmarks (NGB) 3.1. This software is provided "as is"         c
c    without express or implied warranty.                                 c
c                                                                         c
c    Information on NGB 3.1, including the Technical Reports              c
c    NAS-02-005 "NAS Grid Benchmarks Version 1.0" and                     c
c    NAS-04-005 "Evaluating the Information Power Grid using the          c
c    NAS Grid Benchmarks", original specifications, source code,          c
c    results and information on how to submit new results,                c
c    is available at:                                                     c
c                                                                         c
c           http://www.nas.nasa.gov/Software/NPB/                         c
c                                                                         c
c    Send comments or suggestions to  npb@nas.nasa.gov                    c
c                                                                         c
c          NAS Parallel Benchmarks Group                                  c
c          NASA Ames Research Center                                      c
c          Mail Stop: T27A-1                                              c
c          Moffett Field, CA   94035-1000                                 c
c                                                                         c
c          E-mail:  npb@nas.nasa.gov                                      c
c          Fax:     (650) 604-3957                                        c
c                                                                         c
c---------------------------------------------------------------------
c
c Authors: R. Van der Wijngaart
c          M. Frumkin
c          D. Bailey
c          W. Saphir
c
c---------------------------------------------------------------------

c---------------------------------------------------------------------

c---------------------------------------------------------------------
c FT benchmark
c---------------------------------------------------------------------

         program mainft
         implicit none
         include 'global.h'

         integer i, niter, fstatus, init_con, pidlen, ascii, verbose,
     $           width, depth, col_indx
	 character class, graphname*2, pid*16
         data       pidlen /16/
         double precision total_time, mflops
	 logical verified

         read *,     ascii
         read (*,99) graphname
         read (*,99) class
c        skip over reading the NGB class
         read *
         read *,     init_con
         read *,     width
         read *,     depth
         read (*,99) pid
         read *,     verbose
99       format(a)

         open (unit=2,file='timer.flag',status='old',iostat=fstatus)
         if (fstatus .eq. 0) then
            timers_enabled = .true.
            close(2)
         else
            timers_enabled = .false.
         endif

	 niter=niter_default

         niter = max(1,niter/depth)

         if (graphname .eq. 'MB') then
C          WE CHANGE THE NUMBER OF ITERATIONS WITHIN THE LAYER OF FT
C          NODES IN THE MB DATA FLOW GRAPH, BASED ON THE RELATIVE LOCATION
C          OF THE NODE IN THE LAYER (COLUMN INDEX)
           col_indx = mod(init_con,width)
           niter = max(1,int(niter*(1.0-0.5*col_indx/(1.0+col_indx))))
         endif

      	 write(*, 1000)
      	 write(*, 1001) nx, ny, nz
      	 write(*, 1002) niter

 1000    format(//,' NAS Parallel Benchmarks (NPB3.1-SER)',
     >          ' - FT Benchmark', /)
 1001    format(' Size                : ', i3, 'x', i3, 'x', i3)
 1002    format(' Iterations          :     ', i7)

         call appft (niter, total_time, verified, width, depth, 
     >               ascii, class, verbose, init_con, col_indx, 
     >               graphname, pid, pidlen)

      end
      
