c-------------------------------------------------------------------------c
c                                                                         c
c                          G R I D   N P B   3.1                          c
c                                                                         c
c                  N  A  S   G R I D   B E N C H M A R K S                c
c                                                                         c
c                   F 7 7 / S E R I A L    V E R S I O N                  c
c                                                                         c
c                                B T                                      c
c                                                                         c
c-------------------------------------------------------------------------c
c                                                                         c
c    BT solves a (slightly modified) version of the NAS Parallel          c
c    Benchmarks BT code.                                                  c
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
c Authors: R. Van der Wijngaart
c          M. Frumkin
c          T. Harris
c          M. Yarrow
c          H. Jin
c
c---------------------------------------------------------------------

c---------------------------------------------------------------------
       program BT
c---------------------------------------------------------------------

       include  'header.h'
      
       integer          i, niter, step, fstatus, n3, init_con, 
     $                  pidlen, width, depth, ascii, col_indx, verbose
       double precision navg, mflops

       external         timer_read
       double precision tmax, timer_read, t, trecs(t_last)
       logical          verified
       character        class, ngbclass, graphname*2, pid*16, fullname*5
       data             pidlen /16/
       character        t_names(t_last)*8

       read *,     ascii
       read (*,99) fullname
       read (*,99) class
       read (*,99) ngbclass
       read *,     init_con
       read *,     width
       read *,     depth
       read (*,99) pid
       read *,     verbose
99     format(a)

       graphname=fullname(1:2)

c---------------------------------------------------------------------
c      Root node reads input file (if it exists) else takes
c      defaults from parameters
c---------------------------------------------------------------------
          
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
         t_names(t_add) = 'add'
         close(2)
       else
         timeron = .false.
       endif

       write(*, 1000)
 1000  format(//, ' NAS Parallel Benchmarks (NPB3.1-SER)',
     >            ' - BT Benchmark',/)

       niter = niter_default
       dt    = dt_default
       grid_points(1) = problem_size
       grid_points(2) = problem_size
       grid_points(3) = problem_size

       niter = max(1,niter/depth)

       if (class .eq. 'S') dt = dt*0.5d0

       if (graphname .eq. 'MB') then
C        WE CHANGE THE NUMBER OF ITERATIONS WITHIN THE LAYER OF BT
C        NODES IN THE MB DATA FLOW GRAPH, BASED ON THE RELATIVE LOCATION
C        OF THE NODE IN THE LAYER
         col_indx = mod(init_con,width)
         niter = max(1,int(niter*(1.0-0.5*col_indx/(1.0+col_indx))))
       endif

       write(*, 1001) grid_points(1), grid_points(2), grid_points(3)
       write(*, 1002) niter, dt

 1001  format(' Size: ', i3, 'x', i3, 'x', i3)
 1002  format(' Iterations: ', i3, '    dt: ', F10.6)

       if ( (grid_points(1) .gt. IMAX) .or.
     >      (grid_points(2) .gt. JMAX) .or.
     >      (grid_points(3) .gt. KMAX) ) then
             print *, (grid_points(i),i=1,3)
             print *,' Problem size too big for compiled array sizes'
             goto 999
       endif

       call set_constants

       call initialize(ascii, graphname, class, init_con, pid, pidlen)
       do i = 1, t_last
          call timer_clear(i)
       end do

       call exact_rhs(init_con, fullname, width, depth, ngbclass)

       call timer_start(1)

       do  step = 1, niter

          if (mod(step, 20) .eq. 0 .or. step .eq. niter .or.
     >        step .eq. 1) then
             write(*, 200) step
 200         format(' Time step ', i4)
          endif

          call adi

       end do

       call timer_stop(1)
       tmax = timer_read(1)
       
       if (verbose .eq. 1) then
c        bogus call to verify to compute solution and residual norms
         call verify
         verified = .true.

         n3 = grid_points(1)*grid_points(2)*grid_points(3)
         navg = (grid_points(1)+grid_points(2)+grid_points(3))/3.0
         if( tmax .ne. 0. ) then
           mflops = 1.0e-6*float(niter)*
     >     (3478.8*float(n3)-17655.7*navg**2+28023.7*navg) / tmax
         else
           mflops = 0.0
         endif
         call print_results('BT', class, grid_points(1), 
     >   grid_points(2), grid_points(3), niter,
     >   tmax, mflops, '          floating point', 
     >   verified, npbversion,compiletime, cs1, cs2, cs3, cs4, cs5, 
     >    cs6)
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

       if (graphname .eq. 'HC' .or. graphname .eq. 'MB') then
         call dump_solution(ascii, graphname, init_con, pid, pidlen)
       elseif (graphname .eq. 'VP') then
         if (init_con .lt. width*(depth-1)) then
           call dump_solution(ascii, graphname, init_con, pid, pidlen)
         endif
         call dump_machnumber(ascii, graphname, init_con, pid, pidlen)
       endif

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
       if (name .eq. 'VP') then
         call join(outfile, outfilelen, 'BT',2)
       endif
       print *, 'File to be dumped is named:', outfile
       if (ascii .eq. 0) then
         fileform = 'unformatted'
       elseif (ascii .eq. 1) then
         fileform = 'formatted'
       else
         print *, 'Failure: Illegal data format: ', ascii
         stop 870
       endif
       open(10,file=outfile,form=fileform,status='unknown',
     $      iostat=stat)
       if (stat .ne. 0) then
         print *, 'Failure: Could not open bt output file'
         stop 871
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
         print *, 'EOF encountered while writing bt output file'
         stop 872
       elseif (stat .gt. 0) then
         print *, 'Error encountered while writing bt output file'
         stop 873
       endif

       return
       end


c      When the Mach number gets computed and written to file,
c      the original vector of flow variables gets destroyed

       subroutine dump_machnumber(ascii, name, init_con, pid, pidlen)

       include 'header.h'

       integer init_con, pidlen, taillen, outfilelen, i, j, k, m, 
     $         ascii, stat
       double precision rho_inv
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
       do k=0, grid_points(3)-1
         do j=0, grid_points(2)-1
           do i=0,grid_points(1)-1
             rho_inv = 1.d0/u(1,i,j,k)
             u(5,i,j,k) = dsqrt((u(5,i,j,k)- 0.5d0*(
     *                           u(2,i,j,k)*u(2,i,j,k) +
     *                           u(3,i,j,k)*u(3,i,j,k) +
     *                           u(4,i,j,k)*u(4,i,j,k))*rho_inv)*
     *                           rho_inv*0.56d0)
           enddo
         enddo
       enddo

       if (ascii .eq. 0) then
         fileform = 'unformatted'
       elseif (ascii .eq. 1) then
         fileform = 'formatted'
       else
         print *, 'Failure: Illegal data format: ', ascii
         stop 874
       endif
       open(10,file=outfile,form=fileform,status='unknown',
     $      iostat=stat)
       if (stat .ne. 0) then
         print *, 'Failure: Could not open bt output file'
         stop 875
       elseif (ascii .eq. 0) then
         write (10,iostat=stat) (((u(5,i,j,k), 
     $                             i=0,grid_points(1)-1),
     $                             j=0,grid_points(2)-1),
     $                             k=0,grid_points(3)-1)
       else
         write (10,99,iostat=stat) (((u(5,i,j,k), 
     $                               i=0,grid_points(1)-1),
     $                               j=0,grid_points(2)-1),
     $                               k=0,grid_points(3)-1)
99       format(500(e20.13))
       endif              

       if     (stat .lt. 0) then
         print *, 'EOF encountered while writing bt Mach output file'
         stop 876
       elseif (stat .gt. 0) then
         print *, 'Error encountered while writing bt Mach output file'
         stop 877
       endif

       return
       end

