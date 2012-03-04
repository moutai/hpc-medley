c-------------------------------------------------------------------------c
c                                                                         c
c                          G R I D   N P B   3.1                          c
c                                                                         c
c                  N  A  S   G R I D   B E N C H M A R K S                c
c                                                                         c
c                   F 7 7 / S E R I A L    V E R S I O N                  c
c                                                                         c
c                                L U                                      c
c                                                                         c
c-------------------------------------------------------------------------c
c                                                                         c
c    LU solves a (slightly modified) version of the NAS Parallel          c
c    Benchmarks LU code.                                                  c
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
c          S. Weeratunga
c          V. Venkatakrishnan
c          E. Barszcz
c          M. Yarrow
c          H. Jin
c
c---------------------------------------------------------------------

c---------------------------------------------------------------------
      program applu
c---------------------------------------------------------------------

c---------------------------------------------------------------------
c
c   driver for the performance evaluation of the solver for
c   five coupled parabolic/elliptic partial differential equations.
c
c---------------------------------------------------------------------

      implicit none

      include 'applu.incl'
      integer          init_con, pidlen, ascii, width, depth, verbose
      character        class, graphname*2, pid*16
      logical          verified
      double precision mflops
      data             pidlen /16/

      double precision t, tmax, timer_read, trecs(t_last)
      external timer_read
      integer i, fstatus
      character t_names(t_last)*8

      read *,     ascii
      read (*,99) graphname
      read (*,99) class
c     skip over reading the NGB class      
      read *     
      read *,     init_con
      read *,     width
      read *,     depth
      read (*,99) pid
      read *,     verbose
99    format(a)

c---------------------------------------------------------------------
c     Setup info for timers
c---------------------------------------------------------------------

      open (unit=2,file='timer.flag',status='old',iostat=fstatus)
      if (fstatus .eq. 0) then
         timeron = .true.
         t_names(t_total) = 'total'
         t_names(t_rhsx) = 'rhsx'
         t_names(t_rhsy) = 'rhsy'
         t_names(t_rhsz) = 'rhsz'
         t_names(t_rhs) = 'rhs'
         t_names(t_jacld) = 'jacld'
         t_names(t_blts) = 'blts'
         t_names(t_jacu) = 'jacu'
         t_names(t_buts) = 'buts'
         t_names(t_add) = 'add'
         t_names(t_l2norm) = 'l2norm'
         close(2)
      else
         timeron = .false.
      endif

c---------------------------------------------------------------------
c   read input data
c---------------------------------------------------------------------
      call read_input(graphname, init_con, width, depth)

      if (class .eq. 'S') dt = dt*0.5d0

c---------------------------------------------------------------------
c   set up domain sizes
c---------------------------------------------------------------------
      call domain()

c---------------------------------------------------------------------
c   set up coefficients
c---------------------------------------------------------------------
      call setcoeff(graphname, class, init_con, width, depth)

c---------------------------------------------------------------------
c   set the boundary values for dependent variables
c---------------------------------------------------------------------
      call setbv()

c---------------------------------------------------------------------
c   set the initial values for dependent variables
c---------------------------------------------------------------------
      call setiv(ascii, graphname, init_con, pid, pidlen, width)

c---------------------------------------------------------------------
c   compute the forcing term based on prescribed exact solution
c---------------------------------------------------------------------
      call erhs()

c---------------------------------------------------------------------
c   perform the SSOR iterations
c---------------------------------------------------------------------
      call ssor()

c---------------------------------------------------------------------
c   compute the solution error
c---------------------------------------------------------------------
      call error()

c---------------------------------------------------------------------
c   compute the surface integral
c---------------------------------------------------------------------
      call pintgr()

c---------------------------------------------------------------------
c   verification test
c---------------------------------------------------------------------

      if ((graphname .eq. 'HC' .and. init_con .eq. width*depth-1) .or.
     $    verbose .eq. 1) then
        call verify ( rsdnm, errnm, frc, class, verified, graphname,
     $                width, depth, init_con )
        mflops = float(itmax)*(1984.77*float( nx0 )
     >     *float( ny0 )
     >     *float( nz0 )
     >     -10923.3*(float( nx0+ny0+nz0 )/3.)**2 
     >     +27770.9* float( nx0+ny0+nz0 )/3.
     >     -144010.)
     >     / (maxtime*1000000.)

        call print_results('LU', class, nx0,
     >    ny0, nz0, itmax,
     >    maxtime, mflops, '          floating point', verified, 
     >    npbversion, compiletime, cs1, cs2, cs3, cs4, cs5, cs6)
      endif

      if (((graphname .eq. 'HC') .and. (init_con .lt. width*depth-1))
     $     .or. ((graphname .eq. 'MB') .and. 
     $           (init_con .lt. width*(depth-3)))) then
        call dump_solution(ascii, graphname, init_con, pid, pidlen)
      elseif (graphname .eq. 'MB') then
        call dump_machnumber(ascii, graphname, init_con, pid, pidlen)
      endif

c---------------------------------------------------------------------
c      More timers
c---------------------------------------------------------------------
      if (.not.timeron) goto 999
      write(*,800)
 800  format('  SECTION     Time (secs)')
      do i=1, t_last
         trecs(i) = timer_read(i)
      end do
      tmax = maxtime
      if ( tmax .eq. 0. ) tmax = 1.0
      do i=1, t_last
         write(*,810) t_names(i), trecs(i), trecs(i)*100./tmax
         if (i.eq.t_rhs) then
            t = trecs(t_rhsx) + trecs(t_rhsy) + trecs(t_rhsz)
            write(*,820) 'sub-rhs', t, t*100./tmax
            t = trecs(i) - t
            write(*,820) 'rest-rhs', t, t*100./tmax
         endif
 810     format(2x,a8,':',f9.3,'  (',f6.2,'%)')
 820     format(5x,'--> total ',a8,':',f9.3,'  (',f6.2,'%)')
      end do

 999  continue
      end


       subroutine dump_solution(ascii, name, init_con, pid, pidlen)

       include 'applu.incl'
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
         stop 770
       endif
       open(10,file=outfile,form=fileform,status='unknown',
     $      iostat=stat)

       if (stat .ne. 0) then
         print *, 'Failure: Could not open lu output file'
         stop 771
       elseif (ascii .eq. 0) then
         write (10,iostat=stat) 
     $         ((((u(m,i,j,k), m=1,5),i=1,nx),j=1,ny),k=1,nz)
       else
         write (10,99,iostat=stat) 
     $         ((((u(m,i,j,k), m=1,5),i=1,nx),j=1,ny),k=1,nz)
99       format(500(e20.13))
       endif       

       if     (stat .lt. 0) then
         print *, 'EOF encountered while writing lu output file'
         stop 772
       elseif (stat .gt. 0) then
         print *, 'Error encountered while writing lu output file'
         stop 773
       endif

       return
       end


c      When the Mach number gets computed and written to file,
c      the original vector of flow variables gets destroyed

       subroutine dump_machnumber(ascii, name, init_con, pid, pidlen)

       include 'applu.incl'

       integer init_con, pidlen, taillen, outfilelen, i, j, k, m, 
     $         ascii, stat
       double precision rho_inv
       character name*2, outfile*100, tail*10, fileform*12
       character*(*) pid
       data taillen, outfilelen /10,100/

       call blankout(outfile, outfilelen)
       call blankout(tail, taillen)
       outfile = name
c      in MB the name of the output file is that of the producer node
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
         stop 774
       endif

       do k=1, nz
         do j = 1, ny
           do i = 1, nx
             rho_inv = 1.d0/u(1,i,j,k)
             u(5,i,j,k) = dsqrt((u(5,i,j,k)- 0.5d0*(
     *                           u(2,i,j,k)*u(2,i,j,k) +
     *                           u(3,i,j,k)*u(3,i,j,k) +
     *                           u(4,i,j,k)*u(4,i,j,k))*rho_inv)*
     *                           rho_inv*0.56d0)
           enddo
         enddo
       enddo

       open(10,file=outfile,form=fileform,status='unknown',iostat=stat)

       if (stat .ne. 0) then
         print *, 'Failure: Could not open lu Mach output file'
         stop 775
       elseif (ascii .eq. 0) then
         write (10,iostat=stat) 
     $         (((u(5,i,j,k), i=1,nx), j=1,ny), k=1,nz)
       else
         write (10,99,iostat=stat) 
     $         (((u(5,i,j,k), i=1,nx), j=1,ny), k=1,nz)
99       format(500(e20.13))
       endif   

       if     (stat .lt. 0) then
         print *, 'EOF encountered while writing lu Mach output file'
         stop 776
       elseif (stat .gt. 0) then
         print *, 'Error encountered while writing lu Mach output file'
         stop 777
       endif           

       return
       end


