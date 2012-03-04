c-------------------------------------------------------------------------c
c                                                                         c
c                          G R I D   N P B   3.1                          c
c                                                                         c
c                  N  A  S   G R I D   B E N C H M A R K S                c
c                                                                         c
c                   F 7 7 / S E R I A L    V E R S I O N                  c
c                                                                         c
c                                M G                                      c
c                                                                         c
c-------------------------------------------------------------------------c
c                                                                         c
c    MG solves a (slightly modified) version of the NAS Parallel          c
c    Benchmarks MG code.                                                  c
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
c          E. Barszcz
c          P. Frederickson
c          A. Woo
c          M. Yarrow
c
c---------------------------------------------------------------------


c---------------------------------------------------------------------
      program mg
c---------------------------------------------------------------------

      implicit none

      include 'globals.h'

c---------------------------------------------------------------------------c
c k is the current level. It is passed down through subroutine args
c and is NOT global. it is the current iteration
c---------------------------------------------------------------------------c

      integer          k, it, init_con, pidlen, width, depth, ascii, 
     $                 col_indx, verbose
      character        graphname*2, pid*16
      data             pidlen /16/ 
      
      external         timer_read
      double precision t, tinit, mflops, timer_read

c---------------------------------------------------------------------------c
c These arrays are in common because they are quite large
c and probably shouldn't be allocated on the stack. They
c are always passed as subroutine args. 
c---------------------------------------------------------------------------c

      double precision u(nr),v(nv),r(nr),a(0:3),c(0:3)
      common /noautom/ u,v,r   

      double precision rnm2, rnmu, old2, oldu, epsilon
      integer n1, n2, n3, nn, nit
      double precision verify_value
      logical verified

      integer ierr,i, fstatus
      integer T_bench, T_init
      parameter (T_bench=1, T_init=2)

       read *,     ascii
       read (*,99) graphname
       read (*,99) class
c      skip over reading the NGB class
       read *
       read *,     init_con
       read *,     width
       read *,     depth
       read (*,99) pid
       read *,     verbose
99     format(a)

      call timer_clear(T_bench)
      call timer_clear(T_init)

      call timer_start(T_init)
      

c---------------------------------------------------------------------
c Set input data
c---------------------------------------------------------------------

      write (*, 1000) 
 1000 format(//,' NAS Parallel Benchmarks 3.1-SER',
     >          ' - MG Benchmark', /)

      lt = lt_default
      nit = nit_default
      nx(lt) = nx_default
      ny(lt) = ny_default
      nz(lt) = nz_default

      nit = max(1,nit/width)
      if (graphname .eq. 'MB') then
C       WE CHANGE THE NUMBER OF ITERATIONS WITHIN THE LAYER OF MG
C       NODES IN THE MB DATA FLOW GRAPH, BASED ON THE RELATIVE LOCATION
C       OF THE NODE IN THE LAYER (COLUMN INDEX)
        col_indx = mod(init_con,width)      
        nit = max(1,int(nit*(1.0-0.5*col_indx/(1.0+col_indx))))
      endif

      a(0) = -8.0D0/3.0D0 
      a(1) =  0.0D0 
      a(2) =  1.0D0/6.0D0 
      a(3) =  1.0D0/12.0D0
      
      if(Class .eq. 'A' .or. Class .eq. 'S'.or. Class .eq.'W') then
c---------------------------------------------------------------------
c     Coefficients for the S(a) smoother
c---------------------------------------------------------------------
         c(0) =  -3.0D0/8.0D0
         c(1) =  +1.0D0/32.0D0
         c(2) =  -1.0D0/64.0D0
         c(3) =   0.0D0
      else
c---------------------------------------------------------------------
c     Coefficients for the S(b) smoother
c---------------------------------------------------------------------
         c(0) =  -3.0D0/17.0D0
         c(1) =  +1.0D0/33.0D0
         c(2) =  -1.0D0/61.0D0
         c(3) =   0.0D0
      endif
      lb = 1
      k  = lt

      call setup(n1,n2,n3,k)
      call zero3(u,n1,n2,n3)
      call zran3(v,n1,n2,n3,k, ascii, graphname, init_con, 
     $           pid, pidlen)

      call norm2u3(v,n1,n2,n3,rnm2,rnmu,nx(lt),ny(lt),nz(lt))

      write (*, 1001) nx(lt),ny(lt),nz(lt), Class
      write (*, 1002) nit

 1001 format(' Size: ', i3, 'x', i3, 'x', i3, '  (class ', A, ')' )
 1002 format(' Iterations: ', i3)


      call resid(u,v,r,n1,n2,n3,a,k)
      call norm2u3(r,n1,n2,n3,rnm2,rnmu,nx(lt),ny(lt),nz(lt))
      old2 = rnm2
      oldu = rnmu

      call timer_stop(T_init)
      call timer_start(T_bench)

      old2 = rnm2
      oldu = rnmu

      do  it=1,nit
         call mg3P(u,v,r,a,c,n1,n2,n3,k)
         call resid(u,v,r,n1,n2,n3,a,k)
      enddo

      call timer_stop(T_bench)

      t = timer_read(T_bench)
      tinit = timer_read(T_init)

      write( *,'(/A,F15.3,A/)' ) 
     >     ' Initialization time: ',tinit, ' seconds'
      write(*,100)
 100  format(' Benchmark completed ')

      if (verbose .eq. 1) then

        verified = .true.
        call norm2u3(r,n1,n2,n3,rnm2,rnmu,nx(lt),ny(lt),nz(lt))
        write(*, 301) rnm2
 301    format(' L2 Norm is             ', E20.12)

        write(*, 2022)
 2022   format(' No reference values provided')

        nn = nx(lt)*ny(lt)*nz(lt)

        if( t .ne. 0. ) then
          mflops = 58.*nit*nn*1.0D-6 /t
        else
          mflops = 0.0
        endif

        call print_results('MG', class, nx(lt), ny(lt), nz(lt), 
     >                     nit, t,
     >                     mflops, '          floating point', 
     >                     verified, npbversion, compiletime,
     >                     cs1, cs2, cs3, cs4, cs5, cs6)
       endif

       if ((graphname .eq. 'VP') .or. (graphname .eq. 'MB')) then
         call dump_solution(ascii, graphname, init_con, pid, 
     $                      pidlen, u, n1, n2, n3)
       endif

      end


       subroutine dump_solution(ascii, name, init_con, pid, pidlen,
     $                          u,n1,n2,n3)

       include 'globals.h'

       integer init_con, pidlen, taillen, outfilelen, i, j, k, stat
       character name*2, outfile*100, tail*10, fileform*12
       character*(*) pid
       data taillen, outfilelen /10,100/
       integer n1, n2, n3, ascii
       double precision u(n1,n2,n3)

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
         stop 970
       endif
       open(10,file=outfile,form=fileform,status='unknown',
     $        iostat=stat)
       if (stat .ne. 0) then
         print *, 'Failure: Could not open mg output file'
         stop 971
       elseif (ascii .eq. 0) then
         write (10,iostat=stat) 
     $         (((u(i,j,k), i=2,n1-1), j=2,n2-1), k=2,n3-1)       
       else
         write (10,99,iostat=stat) 
     $         (((u(i,j,k), i=2,n1-1), j=2,n2-1), k=2,n3-1)       
99       format(500(e20.13))
       endif

       if     (stat .lt. 0) then
         print *, 'EOF encountered while writing mg output file'
         stop 972
       elseif (stat .gt. 0) then
         print *, 'Error encountered while writing mg output file'
         stop 973
       endif

       return
       end


c---------------------------------------------------------------------
c---------------------------------------------------------------------

      subroutine setup(n1,n2,n3,k)

c---------------------------------------------------------------------
c---------------------------------------------------------------------

      implicit none

      include 'globals.h'

      integer  is1, is2, is3, ie1, ie2, ie3
      common /grid/ is1,is2,is3,ie1,ie2,ie3

      integer n1,n2,n3,k
      integer d, i, j

      integer ax, mi(3,10)
      integer ng(3,10)
      integer s, dir,ierr


      ng(1,lt) = nx(lt)
      ng(2,lt) = ny(lt)
      ng(3,lt) = nz(lt)
      do  ax=1,3
         do  k=lt-1,1,-1
            ng(ax,k) = ng(ax,k+1)/2
         enddo
      enddo
 61   format(10i4)
      do  k=lt,1,-1
         nx(k) = ng(1,k)
         ny(k) = ng(2,k)
         nz(k) = ng(3,k)
      enddo

      do  k = lt,1,-1
         do  ax = 1,3
            mi(ax,k) = 2 + ng(ax,k) 
         enddo

         m1(k) = mi(1,k)
         m2(k) = mi(2,k)
         m3(k) = mi(3,k)

      enddo

      k = lt
      is1 = 2 + ng(1,k) - ng(1,lt)
      ie1 = 1 + ng(1,k)
      n1 = 3 + ie1 - is1
      is2 = 2 + ng(2,k) - ng(2,lt)
      ie2 = 1 + ng(2,k) 
      n2 = 3 + ie2 - is2
      is3 = 2 + ng(3,k) - ng(3,lt)
      ie3 = 1 + ng(3,k) 
      n3 = 3 + ie3 - is3


      ir(lt)=1
      do  j = lt-1, 1, -1
         ir(j)=ir(j+1)+m1(j+1)*m2(j+1)*m3(j+1)
      enddo

      k = lt

      return
      end

c---------------------------------------------------------------------
c---------------------------------------------------------------------

      subroutine mg3P(u,v,r,a,c,n1,n2,n3,k)

c---------------------------------------------------------------------
c---------------------------------------------------------------------

c---------------------------------------------------------------------
c     multigrid V-cycle routine
c---------------------------------------------------------------------
      implicit none

      include 'globals.h'

      integer n1, n2, n3, k
      double precision u(nr),v(nv),r(nr)
      double precision a(0:3),c(0:3)

      integer j

c---------------------------------------------------------------------
c     down cycle.
c     restrict the residual from the find grid to the coarse
c---------------------------------------------------------------------

      do  k= lt, lb+1 , -1
         j = k-1
         call rprj3(r(ir(k)),m1(k),m2(k),m3(k),
     >        r(ir(j)),m1(j),m2(j),m3(j),k)
      enddo

      k = lb
c---------------------------------------------------------------------
c     compute an approximate solution on the coarsest grid
c---------------------------------------------------------------------
      call zero3(u(ir(k)),m1(k),m2(k),m3(k))
      call psinv(r(ir(k)),u(ir(k)),m1(k),m2(k),m3(k),c,k)

      do  k = lb+1, lt-1     
          j = k-1
c---------------------------------------------------------------------
c        prolongate from level k-1  to k
c---------------------------------------------------------------------
         call zero3(u(ir(k)),m1(k),m2(k),m3(k))
         call interp(u(ir(j)),m1(j),m2(j),m3(j),
     >               u(ir(k)),m1(k),m2(k),m3(k),k)
c---------------------------------------------------------------------
c        compute residual for level k
c---------------------------------------------------------------------
         call resid(u(ir(k)),r(ir(k)),r(ir(k)),m1(k),m2(k),m3(k),a,k)
c---------------------------------------------------------------------
c        apply smoother
c---------------------------------------------------------------------
         call psinv(r(ir(k)),u(ir(k)),m1(k),m2(k),m3(k),c,k)
      enddo
 200  continue
      j = lt - 1
      k = lt
      call interp(u(ir(j)),m1(j),m2(j),m3(j),u,n1,n2,n3,k)
      call resid(u,v,r,n1,n2,n3,a,k)
      call psinv(r,u,n1,n2,n3,c,k)

      return
      end

c---------------------------------------------------------------------
c---------------------------------------------------------------------

      subroutine psinv( r,u,n1,n2,n3,c,k)

c---------------------------------------------------------------------
c---------------------------------------------------------------------

c---------------------------------------------------------------------
c     psinv applies an approximate inverse as smoother:  u = u + Cr
c
c     This  implementation costs  15A + 4M per result, where
c     A and M denote the costs of Addition and Multiplication.  
c     Presuming coefficient c(3) is zero (the NPB assumes this,
c     but it is thus not a general case), 2A + 1M may be eliminated,
c     resulting in 13A + 3M.
c     Note that this vectorizes, and is also fine for cache 
c     based machines.  
c---------------------------------------------------------------------
      implicit none

      include 'globals.h'

      integer n1,n2,n3,k
      double precision u(n1,n2,n3),r(n1,n2,n3),c(0:3)
      integer i3, i2, i1

      double precision r1(m), r2(m)
      
      do i3=2,n3-1
         do i2=2,n2-1
            do i1=1,n1
               r1(i1) = r(i1,i2-1,i3) + r(i1,i2+1,i3)
     >                + r(i1,i2,i3-1) + r(i1,i2,i3+1)
               r2(i1) = r(i1,i2-1,i3-1) + r(i1,i2+1,i3-1)
     >                + r(i1,i2-1,i3+1) + r(i1,i2+1,i3+1)
            enddo
            do i1=2,n1-1
               u(i1,i2,i3) = u(i1,i2,i3)
     >                     + c(0) * r(i1,i2,i3)
     >                     + c(1) * ( r(i1-1,i2,i3) + r(i1+1,i2,i3)
     >                              + r1(i1) )
     >                     + c(2) * ( r2(i1) + r1(i1-1) + r1(i1+1) )
c---------------------------------------------------------------------
c  Assume c(3) = 0    (Enable line below if c(3) not= 0)
c---------------------------------------------------------------------
c    >                     + c(3) * ( r2(i1-1) + r2(i1+1) )
c---------------------------------------------------------------------
            enddo
         enddo
      enddo

c---------------------------------------------------------------------
c     exchange boundary points
c---------------------------------------------------------------------
      call comm3(u,n1,n2,n3,k)

      return
      end

c---------------------------------------------------------------------
c---------------------------------------------------------------------

      subroutine resid( u,v,r,n1,n2,n3,a,k )

c---------------------------------------------------------------------
c---------------------------------------------------------------------

c---------------------------------------------------------------------
c     resid computes the residual:  r = v - Au
c
c     This  implementation costs  15A + 4M per result, where
c     A and M denote the costs of Addition (or Subtraction) and 
c     Multiplication, respectively. 
c     Presuming coefficient a(1) is zero (the NPB assumes this,
c     but it is thus not a general case), 3A + 1M may be eliminated,
c     resulting in 12A + 3M.
c     Note that this vectorizes, and is also fine for cache 
c     based machines.  
c---------------------------------------------------------------------
      implicit none

      include 'globals.h'

      integer n1,n2,n3,k
      double precision u(n1,n2,n3),v(n1,n2,n3),r(n1,n2,n3),a(0:3)
      integer i3, i2, i1
      double precision u1(m), u2(m)

      do i3=2,n3-1
         do i2=2,n2-1
            do i1=1,n1
               u1(i1) = u(i1,i2-1,i3) + u(i1,i2+1,i3)
     >                + u(i1,i2,i3-1) + u(i1,i2,i3+1)
               u2(i1) = u(i1,i2-1,i3-1) + u(i1,i2+1,i3-1)
     >                + u(i1,i2-1,i3+1) + u(i1,i2+1,i3+1)
            enddo
            do i1=2,n1-1
               r(i1,i2,i3) = v(i1,i2,i3)
     >                     - a(0) * u(i1,i2,i3)
c---------------------------------------------------------------------
c  Assume a(1) = 0      (Enable 2 lines below if a(1) not= 0)
c---------------------------------------------------------------------
c    >                     - a(1) * ( u(i1-1,i2,i3) + u(i1+1,i2,i3)
c    >                              + u1(i1) )
c---------------------------------------------------------------------
     >                     - a(2) * ( u2(i1) + u1(i1-1) + u1(i1+1) )
     >                     - a(3) * ( u2(i1-1) + u2(i1+1) )
            enddo
         enddo
      enddo

c---------------------------------------------------------------------
c     exchange boundary data
c---------------------------------------------------------------------
      call comm3(r,n1,n2,n3,k)

      return
      end

c---------------------------------------------------------------------
c---------------------------------------------------------------------

      subroutine rprj3( r,m1k,m2k,m3k,s,m1j,m2j,m3j,k )

c---------------------------------------------------------------------
c---------------------------------------------------------------------

c---------------------------------------------------------------------
c     rprj3 projects onto the next coarser grid, 
c     using a trilinear Finite Element projection:  s = r' = P r
c     
c     This  implementation costs  20A + 4M per result, where
c     A and M denote the costs of Addition and Multiplication.  
c     Note that this vectorizes, and is also fine for cache 
c     based machines.  
c---------------------------------------------------------------------
      implicit none

      include 'globals.h'

      integer m1k, m2k, m3k, m1j, m2j, m3j,k
      double precision r(m1k,m2k,m3k), s(m1j,m2j,m3j)
      integer j3, j2, j1, i3, i2, i1, d1, d2, d3, j

      double precision x1(m), y1(m), x2,y2


      if(m1k.eq.3)then
        d1 = 2
      else
        d1 = 1
      endif

      if(m2k.eq.3)then
        d2 = 2
      else
        d2 = 1
      endif

      if(m3k.eq.3)then
        d3 = 2
      else
        d3 = 1
      endif

      do  j3=2,m3j-1
         i3 = 2*j3-d3
C        i3 = 2*j3-1
         do  j2=2,m2j-1
            i2 = 2*j2-d2
C           i2 = 2*j2-1

            do j1=2,m1j
              i1 = 2*j1-d1
C             i1 = 2*j1-1
              x1(i1-1) = r(i1-1,i2-1,i3  ) + r(i1-1,i2+1,i3  )
     >                 + r(i1-1,i2,  i3-1) + r(i1-1,i2,  i3+1)
              y1(i1-1) = r(i1-1,i2-1,i3-1) + r(i1-1,i2-1,i3+1)
     >                 + r(i1-1,i2+1,i3-1) + r(i1-1,i2+1,i3+1)
            enddo

            do  j1=2,m1j-1
              i1 = 2*j1-d1
C             i1 = 2*j1-1
              y2 = r(i1,  i2-1,i3-1) + r(i1,  i2-1,i3+1)
     >           + r(i1,  i2+1,i3-1) + r(i1,  i2+1,i3+1)
              x2 = r(i1,  i2-1,i3  ) + r(i1,  i2+1,i3  )
     >           + r(i1,  i2,  i3-1) + r(i1,  i2,  i3+1)
              s(j1,j2,j3) =
     >               0.5D0 * r(i1,i2,i3)
     >             + 0.25D0 * ( r(i1-1,i2,i3) + r(i1+1,i2,i3) + x2)
     >             + 0.125D0 * ( x1(i1-1) + x1(i1+1) + y2)
     >             + 0.0625D0 * ( y1(i1-1) + y1(i1+1) )
            enddo

         enddo
      enddo


      j = k-1
      call comm3(s,m1j,m2j,m3j,j)

      return
      end

c---------------------------------------------------------------------
c---------------------------------------------------------------------

      subroutine interp( z,mm1,mm2,mm3,u,n1,n2,n3,k )

c---------------------------------------------------------------------
c---------------------------------------------------------------------

c---------------------------------------------------------------------
c     interp adds the trilinear interpolation of the correction
c     from the coarser grid to the current approximation:  u = u + Qu'
c     
c     Observe that this  implementation costs  16A + 4M, where
c     A and M denote the costs of Addition and Multiplication.  
c     Note that this vectorizes, and is also fine for cache 
c     based machines.  Vector machines may get slightly better 
c     performance however, with 8 separate "do i1" loops, rather than 4.
c---------------------------------------------------------------------
      implicit none

      include 'globals.h'

      integer mm1, mm2, mm3, n1, n2, n3,k
      double precision z(mm1,mm2,mm3),u(n1,n2,n3)
      integer i3, i2, i1, d1, d2, d3, t1, t2, t3

c note that m = 1037 in globals.h but for this only need to be
c 535 to handle up to 1024^3
c      integer m
c      parameter( m=535 )
      double precision z1(m),z2(m),z3(m)


      if( n1 .ne. 3 .and. n2 .ne. 3 .and. n3 .ne. 3 ) then

         do  i3=1,mm3-1
            do  i2=1,mm2-1

               do i1=1,mm1
                  z1(i1) = z(i1,i2+1,i3) + z(i1,i2,i3)
                  z2(i1) = z(i1,i2,i3+1) + z(i1,i2,i3)
                  z3(i1) = z(i1,i2+1,i3+1) + z(i1,i2,i3+1) + z1(i1)
               enddo

               do  i1=1,mm1-1
                  u(2*i1-1,2*i2-1,2*i3-1)=u(2*i1-1,2*i2-1,2*i3-1)
     >                 +z(i1,i2,i3)
                  u(2*i1,2*i2-1,2*i3-1)=u(2*i1,2*i2-1,2*i3-1)
     >                 +0.5d0*(z(i1+1,i2,i3)+z(i1,i2,i3))
               enddo
               do i1=1,mm1-1
                  u(2*i1-1,2*i2,2*i3-1)=u(2*i1-1,2*i2,2*i3-1)
     >                 +0.5d0 * z1(i1)
                  u(2*i1,2*i2,2*i3-1)=u(2*i1,2*i2,2*i3-1)
     >                 +0.25d0*( z1(i1) + z1(i1+1) )
               enddo
               do i1=1,mm1-1
                  u(2*i1-1,2*i2-1,2*i3)=u(2*i1-1,2*i2-1,2*i3)
     >                 +0.5d0 * z2(i1)
                  u(2*i1,2*i2-1,2*i3)=u(2*i1,2*i2-1,2*i3)
     >                 +0.25d0*( z2(i1) + z2(i1+1) )
               enddo
               do i1=1,mm1-1
                  u(2*i1-1,2*i2,2*i3)=u(2*i1-1,2*i2,2*i3)
     >                 +0.25d0* z3(i1)
                  u(2*i1,2*i2,2*i3)=u(2*i1,2*i2,2*i3)
     >                 +0.125d0*( z3(i1) + z3(i1+1) )
               enddo
            enddo
         enddo

      else

         if(n1.eq.3)then
            d1 = 2
            t1 = 1
         else
            d1 = 1
            t1 = 0
         endif
         
         if(n2.eq.3)then
            d2 = 2
            t2 = 1
         else
            d2 = 1
            t2 = 0
         endif
         
         if(n3.eq.3)then
            d3 = 2
            t3 = 1
         else
            d3 = 1
            t3 = 0
         endif
         
         do  i3=d3,mm3-1
            do  i2=d2,mm2-1
               do  i1=d1,mm1-1
                  u(2*i1-d1,2*i2-d2,2*i3-d3)=u(2*i1-d1,2*i2-d2,2*i3-d3)
     >                 +z(i1,i2,i3)
               enddo
               do  i1=1,mm1-1
                  u(2*i1-t1,2*i2-d2,2*i3-d3)=u(2*i1-t1,2*i2-d2,2*i3-d3)
     >                 +0.5D0*(z(i1+1,i2,i3)+z(i1,i2,i3))
               enddo
            enddo
            do  i2=1,mm2-1
               do  i1=d1,mm1-1
                  u(2*i1-d1,2*i2-t2,2*i3-d3)=u(2*i1-d1,2*i2-t2,2*i3-d3)
     >                 +0.5D0*(z(i1,i2+1,i3)+z(i1,i2,i3))
               enddo
               do  i1=1,mm1-1
                  u(2*i1-t1,2*i2-t2,2*i3-d3)=u(2*i1-t1,2*i2-t2,2*i3-d3)
     >                 +0.25D0*(z(i1+1,i2+1,i3)+z(i1+1,i2,i3)
     >                 +z(i1,  i2+1,i3)+z(i1,  i2,i3))
               enddo
            enddo
         enddo

         do  i3=1,mm3-1
            do  i2=d2,mm2-1
               do  i1=d1,mm1-1
                  u(2*i1-d1,2*i2-d2,2*i3-t3)=u(2*i1-d1,2*i2-d2,2*i3-t3)
     >                 +0.5D0*(z(i1,i2,i3+1)+z(i1,i2,i3))
               enddo
               do  i1=1,mm1-1
                  u(2*i1-t1,2*i2-d2,2*i3-t3)=u(2*i1-t1,2*i2-d2,2*i3-t3)
     >                 +0.25D0*(z(i1+1,i2,i3+1)+z(i1,i2,i3+1)
     >                 +z(i1+1,i2,i3  )+z(i1,i2,i3  ))
               enddo
            enddo
            do  i2=1,mm2-1
               do  i1=d1,mm1-1
                  u(2*i1-d1,2*i2-t2,2*i3-t3)=u(2*i1-d1,2*i2-t2,2*i3-t3)
     >                 +0.25D0*(z(i1,i2+1,i3+1)+z(i1,i2,i3+1)
     >                 +z(i1,i2+1,i3  )+z(i1,i2,i3  ))
               enddo
               do  i1=1,mm1-1
                  u(2*i1-t1,2*i2-t2,2*i3-t3)=u(2*i1-t1,2*i2-t2,2*i3-t3)
     >                 +0.125D0*(z(i1+1,i2+1,i3+1)+z(i1+1,i2,i3+1)
     >                 +z(i1  ,i2+1,i3+1)+z(i1  ,i2,i3+1)
     >                 +z(i1+1,i2+1,i3  )+z(i1+1,i2,i3  )
     >                 +z(i1  ,i2+1,i3  )+z(i1  ,i2,i3  ))
               enddo
            enddo
         enddo

      endif

      return 
      end

c---------------------------------------------------------------------
c---------------------------------------------------------------------

      subroutine norm2u3(r,n1,n2,n3,rnm2,rnmu,nx,ny,nz)

c---------------------------------------------------------------------
c---------------------------------------------------------------------

c---------------------------------------------------------------------
c     norm2u3 evaluates approximations to the L2 norm and the
c     uniform (or L-infinity or Chebyshev) norm, under the
c     assumption that the boundaries are periodic or zero.  Add the
c     boundaries in with half weight (quarter weight on the edges
c     and eighth weight at the corners) for inhomogeneous boundaries.
c---------------------------------------------------------------------
      implicit none


      integer n1, n2, n3, nx, ny, nz
      double precision rnm2, rnmu, r(n1,n2,n3)
      double precision s, a, ss
      integer i3, i2, i1, ierr

      integer n

      n = nx*ny*nz

      s=0.0D0
      rnmu = 0.0D0
      do  i3=2,n3-1
         do  i2=2,n2-1
            do  i1=2,n1-1
               s=s+r(i1,i2,i3)**2
               a=abs(r(i1,i2,i3))
               if(a.gt.rnmu)rnmu=a
            enddo
         enddo
      enddo

      rnm2=sqrt( s / float( n ))

      return
      end

c---------------------------------------------------------------------
c---------------------------------------------------------------------

      subroutine rep_nrm(u,n1,n2,n3,title,kk)

c---------------------------------------------------------------------
c---------------------------------------------------------------------

c---------------------------------------------------------------------
c     report on norm
c---------------------------------------------------------------------
      implicit none

      include 'globals.h'

      integer n1, n2, n3, kk
      double precision u(n1,n2,n3)
      character*8 title

      double precision rnm2, rnmu


      call norm2u3(u,n1,n2,n3,rnm2,rnmu,nx(kk),ny(kk),nz(kk))
      write(*,7)kk,title,rnm2,rnmu
 7    format(' Level',i2,' in ',a8,': norms =',D21.14,D21.14)

      return
      end

c---------------------------------------------------------------------
c---------------------------------------------------------------------

      subroutine comm3(u,n1,n2,n3,kk)

c---------------------------------------------------------------------
c---------------------------------------------------------------------

c---------------------------------------------------------------------
c     comm3 organizes the communication on all borders 
c---------------------------------------------------------------------
      implicit none

      include 'globals.h'

      integer n1, n2, n3, kk
      double precision u(n1,n2,n3)
      integer axis

      do  axis = 1, 3
         call comm1p( axis, u, n1, n2, n3, kk )
      enddo

      return
      end


c---------------------------------------------------------------------
c---------------------------------------------------------------------

      subroutine comm1p( axis, u, n1, n2, n3, kk )

c---------------------------------------------------------------------
c---------------------------------------------------------------------

      implicit none

      include 'globals.h'

      integer axis, dir, n1, n2, n3
      double precision u( n1, n2, n3 )

      integer i3, i2, i1, buff_len,buff_id
      integer i, kk, indx

      dir = -1

      buff_id = 3 + dir
      buff_len = nm2

      do  i=1,nm2
         buff(i,buff_id) = 0.0D0
      enddo


      dir = +1

      buff_id = 3 + dir
      buff_len = nm2

      do  i=1,nm2
         buff(i,buff_id) = 0.0D0
      enddo

      dir = +1

      buff_id = 2 + dir 
      buff_len = 0

      if( axis .eq.  1 )then
         do  i3=2,n3-1
            do  i2=2,n2-1
               buff_len = buff_len + 1
               buff(buff_len, buff_id ) = u( n1-1, i2,i3)
            enddo
         enddo
      endif

      if( axis .eq.  2 )then
         do  i3=2,n3-1
            do  i1=1,n1
               buff_len = buff_len + 1
               buff(buff_len,  buff_id )= u( i1,n2-1,i3)
            enddo
         enddo
      endif

      if( axis .eq.  3 )then
         do  i2=1,n2
            do  i1=1,n1
               buff_len = buff_len + 1
               buff(buff_len, buff_id ) = u( i1,i2,n3-1)
            enddo
         enddo
      endif

      dir = -1

      buff_id = 2 + dir 
      buff_len = 0

      if( axis .eq.  1 )then
         do  i3=2,n3-1
            do  i2=2,n2-1
               buff_len = buff_len + 1
               buff(buff_len,buff_id ) = u( 2,  i2,i3)
            enddo
         enddo
      endif

      if( axis .eq.  2 )then
         do  i3=2,n3-1
            do  i1=1,n1
               buff_len = buff_len + 1
               buff(buff_len, buff_id ) = u( i1,  2,i3)
            enddo
         enddo
      endif

      if( axis .eq.  3 )then
         do  i2=1,n2
            do  i1=1,n1
               buff_len = buff_len + 1
               buff(buff_len, buff_id ) = u( i1,i2,2)
            enddo
         enddo
      endif

      do  i=1,nm2
         buff(i,4) = buff(i,3)
         buff(i,2) = buff(i,1)
      enddo

      dir = -1

      buff_id = 3 + dir
      indx = 0

      if( axis .eq.  1 )then
         do  i3=2,n3-1
            do  i2=2,n2-1
               indx = indx + 1
               u(n1,i2,i3) = buff(indx, buff_id )
            enddo
         enddo
      endif

      if( axis .eq.  2 )then
         do  i3=2,n3-1
            do  i1=1,n1
               indx = indx + 1
               u(i1,n2,i3) = buff(indx, buff_id )
            enddo
         enddo
      endif

      if( axis .eq.  3 )then
         do  i2=1,n2
            do  i1=1,n1
               indx = indx + 1
               u(i1,i2,n3) = buff(indx, buff_id )
            enddo
         enddo
      endif


      dir = +1

      buff_id = 3 + dir
      indx = 0

      if( axis .eq.  1 )then
         do  i3=2,n3-1
            do  i2=2,n2-1
               indx = indx + 1
               u(1,i2,i3) = buff(indx, buff_id )
            enddo
         enddo
      endif

      if( axis .eq.  2 )then
         do  i3=2,n3-1
            do  i1=1,n1
               indx = indx + 1
               u(i1,1,i3) = buff(indx, buff_id )
            enddo
         enddo
      endif

      if( axis .eq.  3 )then
         do  i2=1,n2
            do  i1=1,n1
               indx = indx + 1
               u(i1,i2,1) = buff(indx, buff_id )
            enddo
         enddo
      endif

      return
      end


c---------------------------------------------------------------------
c---------------------------------------------------------------------

      subroutine zran3(z,n1,n2,n3,k,
     $                 ascii, name, init_con, pid, pidlen)

c---------------------------------------------------------------------
c---------------------------------------------------------------------

c---------------------------------------------------------------------
c     Read the initial solution from a file
c---------------------------------------------------------------------
      implicit none

      integer init_con, pidlen, taillen, infilelen, stat, ascii

      character name*2, infile*100, tail*10, fileform*12
      character*(*) pid
      data taillen, infilelen /10,100/

      integer n1, n2, n3, k, ii, jj, kk
      double precision z(n1,n2,n3)
       if ((name .eq. 'VP') .or. (name .eq. 'MB')) then
c        construct the name of the input file and read it
         call blankout(infile, infilelen)
         call blankout(tail, taillen)
         infile = name
         call integer_to_string(tail, taillen, init_con)
         call join(infile,infilelen,tail,taillen)
         call join(infile,infilelen,pid,pidlen)
         call join(infile,infilelen+pidlen,'IN',2)
         print *, 'File to be read is named:', infile
         if (ascii .eq. 0) then
           fileform = 'unformatted'
         elseif (ascii .eq. 1) then
           fileform = 'formatted'
         else
           print *, 'Failure: Illegal data format: ', ascii
           stop 966
         endif
         open(10,file=infile,form=fileform,status='old',
     $        iostat=stat)
         if (stat .ne. 0) then
           print *, 'Failure: Could not open mg input file'
           stop 967
         elseif (ascii .eq. 0) then
           read (10,iostat=stat) 
     $          (((z(ii,jj,kk),ii=2,n1-1),jj=2,n2-1),kk=2,n3-1)
         else
           read (10,99,iostat=stat) 
     $          (((z(ii,jj,kk),ii=2,n1-1),jj=2,n2-1),kk=2,n3-1)
99         format(500(e20.13))
         endif

         if     (stat .lt. 0) then
           print *, 'EOF encountered while reading mg input file'
           stop 968
         elseif (stat .gt. 0) then
           print *, 'Error encountered while reading mg input file'
           stop 969
         endif

         call comm3(z,n1,n2,n3,k)
         return

       endif
c
      return 
      end



c---------------------------------------------------------------------
c---------------------------------------------------------------------


      subroutine zero3(z,n1,n2,n3)

c---------------------------------------------------------------------
c---------------------------------------------------------------------

      implicit none


      integer n1, n2, n3
      double precision z(n1,n2,n3)
      integer i1, i2, i3

      do  i3=1,n3
         do  i2=1,n2
            do  i1=1,n1
               z(i1,i2,i3)=0.0D0
            enddo
         enddo
      enddo

      return
      end


c----- end of program ------------------------------------------------
