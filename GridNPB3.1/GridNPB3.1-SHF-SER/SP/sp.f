c-------------------------------------------------------------------------c
c                                                                         c
c                          G R I D   N P B   3.1                          c
c                                                                         c
c                  N  A  S   G R I D   B E N C H M A R K S                c
c                                                                         c
c                   F 7 7 / S E R I A L    V E R S I O N                  c
c                                                                         c
c                                S P                                      c
c                                                                         c
c-------------------------------------------------------------------------c
c                                                                         c
c    SP solves a (slightly modified) version of the NAS Parallel          c
c    Benchmarks SP code.                                                  c
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
c-------------------------------------------------------------------------c

c---------------------------------------------------------------------
c
c Authors: R. Van der Wijngaart
c          M. Frumkin
c          W. Saphir
c          H. Jin
c---------------------------------------------------------------------

c---------------------------------------------------------------------
       program SP
c---------------------------------------------------------------------

       include  'header.h'
      
       integer          i, niter, step, fstatus, n3, init_con, pidlen,
     $                  col_indx, ascii, width, depth, verbose
       external         timer_read
       double precision mflops, t, tmax, timer_read, trecs(t_last)
       logical          verified
       character        t_names(t_last)*8
       character        class, ngbclass, graphname*2, pid*16
       data             pidlen /16/

c---------------------------------------------------------------------
c      Read input file (if it exists), else take
c      defaults from parameters
c---------------------------------------------------------------------

       read *,     ascii
       read (*,99) graphname
       read (*,99) class
       read (*,99) ngbclass
       read *,     init_con
       read *,     width
       read *,     depth
       read (*,99) pid
       read *,     verbose
99     format(a)
          
       open (unit=2,file='timer.flag',status='old', iostat=fstatus)
       if (fstatus .eq. 0) then
         timeron = .true.
	 t_names(t_total) = 'total'
	 t_names(t_rhsx) = 'rhsx'
	 t_names(t_rhsy) = 'rhsy'
	 t_names(t_rhsz) = 'rhsz'
	 t_names(t_rhs) = 'rhs'
	 t_names(t_xsolve) = 'xsolve'
	 t_names(t_ysolve) = 'ysolve'
	 t_names(t_zsolve) = 'zsolve'
	 t_names(t_rdis1) = 'redist1'
	 t_names(t_rdis2) = 'redist2'
	 t_names(t_tzetar) = 'tzetar'
	 t_names(t_ninvr) = 'ninvr'
	 t_names(t_pinvr) = 'pinvr'
	 t_names(t_txinvr) = 'txinvr'
	 t_names(t_add) = 'add'
         close(2)
       else
         timeron = .false.
       endif

       write(*, 1000)
 1000 format(//,' NAS Parallel Benchmarks (NPB3.1-SER)',
     >          ' - SP Benchmark', /)

       niter = niter_default
       dt    = dt_default
       grid_points(1) = problem_size
       grid_points(2) = problem_size
       grid_points(3) = problem_size

       niter = max(1,niter/depth)
       if (class .eq. 'S' .and. graphname .ne. 'ED') dt = dt*0.5d0

       if (graphname .eq. 'MB') then
C        WE CHANGE THE NUMBER OF ITERATIONS WITHIN THE LAYER OF SP
C        NODES IN THE MB DATA FLOW GRAPH, BASED ON THE RELATIVE LOCATION
C        OF THE NODE IN THE LAYER
         col_indx = mod(init_con,width)
         niter = max(1,int(niter*(1.0-0.5*col_indx/(1.0+col_indx))))
       endif

       write(*, 1001) grid_points(1), grid_points(2), grid_points(3)
       write(*, 1002) niter, dt

 1001     format(' Size: ', i3, 'x', i3, 'x', i3)
 1002     format(' Iterations: ', i3, '    dt: ', F10.6)

       if ( (grid_points(1) .gt. IMAX) .or.
     >      (grid_points(2) .gt. JMAX) .or.
     >      (grid_points(3) .gt. KMAX) ) then
             print *, (grid_points(i),i=1,3)
             print *,' Problem size too big for compiled array sizes'
             goto 999
       endif
       nx2 = grid_points(1) - 2
       ny2 = grid_points(2) - 2
       nz2 = grid_points(3) - 2

       call set_constants(graphname, class, ngbclass, init_con)

       call exact_rhs

       call initialize(ascii, graphname, init_con, width, pid, pidlen)

       do i = 1, t_last
          call timer_clear(i)
       end do

       call timer_start(1)

       do  step = 1, niter

          if (mod(step, 20) .eq. 0 .or. step .eq. 1 .or. 
     $        step .eq. niter) then
             write(*, 200) step
 200         format(' Time step ', i4)
          endif

          call adi

       end do

       call timer_stop(1)
       tmax = timer_read(1)

       if (graphname .eq. 'ED' .or. verbose .eq. 1) then       
         call verify(niter, class, verified, graphname)

         if( tmax .ne. 0. ) then
            n3 = grid_points(1)*grid_points(2)*grid_points(3)
            t = (grid_points(1)+grid_points(2)+grid_points(3))/3.0
            mflops = (881.174 * float( n3 )
     >             -4683.91 * t**2
     >             +11484.5 * t
     >             -19272.4) * float( niter ) / (tmax*1000000.0d0)
         else
            mflops = 0.0
         endif

         call print_results('SP', class, grid_points(1), 
     >       grid_points(2), grid_points(3), niter, 
     >       tmax, mflops, '          floating point', 
     >       verified, npbversion,compiletime, cs1, cs2, cs3, cs4, 
     >       cs5, cs6)
       endif

       if (graphname .eq. 'HC' .or. graphname .eq. 'MB') then
          call dump_solution(ascii, graphname, init_con, pid, pidlen)
       endif      

c---------------------------------------------------------------------
c      More timers
c---------------------------------------------------------------------
       if (.not.timeron) goto 999
       write(*,800)
 800   format('  SECTION   Time (secs)')
       do i=1, t_last
          trecs(i) = timer_read(i)
       end do
       if (tmax .eq. 0.0) tmax = 1.0
       do i=1, t_last
          write(*,810) t_names(i), trecs(i), trecs(i)*100./tmax
	  if (i.eq.t_rhs) then
	     t = trecs(t_rhsx) + trecs(t_rhsy) + trecs(t_rhsz)
	     write(*,820) 'sub-rhs', t, t*100./tmax
	     t = trecs(t_rhs) - t
	     write(*,820) 'rest-rhs', t, t*100./tmax
	  elseif (i.eq.t_zsolve) then
	     t = trecs(t_zsolve) - trecs(t_rdis1) - trecs(t_rdis2)
	     write(*,820) 'sub-zsol', t, t*100./tmax
	  elseif (i.eq.t_rdis2) then
	     t = trecs(t_rdis1) + trecs(t_rdis2)
	     write(*,820) 'redist', t, t*100./tmax
	  endif
 810      format(2x,a8,':',f9.3,'  (',f6.2,'%)')
 820      format('    --> total ',a8,':',f9.3,'  (',f6.2,'%)')
       end do

 999   continue

       end



       subroutine dump_solution(ascii, name, init_con, pid, pidlen)

       include 'header.h'

       integer init_con, pidlen, taillen, outfilelen, i, j, k, m, 
     $         ascii, stat
       character name*2, outfile*100, tail*10, fileform*12
       character*(*) pid
       data taillen, outfilelen /10,100/

       call blankout(outfile, outfilelen)
       call blankout(tail, taillen)
       outfile = name
       call integer_to_string(tail, taillen, init_con)
       call join(outfile, outfilelen, tail, taillen)
       call join(outfile, outfilelen, pid, pidlen)
       print *, 'File to be dumped is named:', outfile
       if (ascii .eq. 0) then
         fileform = 'unformatted'
       elseif (ascii .eq. 1) then
         fileform = 'formatted'
       else
         print *, 'Failure: Illegal data format: ', ascii
         stop 670
       endif
       open(10,file=outfile,form=fileform,status='unknown',
     $      iostat=stat)
       if (stat .ne. 0) then
         print *, 'Failure: Could not open sp output file'
         stop 671
       elseif (ascii .eq. 0) then
         write (10,iostat=stat) ((((u(m,i,j,k), m=1,5),
     $                              i=0,grid_points(1)-1),
     $                              j=0,grid_points(2)-1),
     $                              k=0,grid_points(3)-1)
       else
         write (10,99,iostat=stat) ((((u(m,i,j,k), m=1,5),
     $                                i=0,grid_points(1)-1),
     $                                j=0,grid_points(2)-1),
     $                                k=0,grid_points(3)-1)
99       format(500(e20.13))
       endif       

       if     (stat .lt. 0) then
         print *, 'EOF encountered while writing sp output file'
         stop 672
       elseif (stat .gt. 0) then
         print *, 'Error encountered while writing sp output file'
         stop 673
       endif

       return
       end

