c---------------------------------------------------------------------
c compute the roots-of-unity array that will be used for subsequent FFTs. 
c---------------------------------------------------------------------
      subroutine CompExp (n, exponent)

      implicit none
      integer n
      double complex exponent(n) 
      integer ilog2
      external ilog2      
     
      integer m,nu,ku,i,j,ln
      double precision t, ti, pi 
      data pi /3.141592653589793238d0/

      nu = n
      m = ilog2(n)
      exponent(1) = m
      ku = 2
      ln = 1
      do j = 1, m
         t = pi / ln
         do i = 0, ln - 1
            ti = i * t
            exponent(i+ku) = dcmplx(cos(ti),sin(ti))
         enddo        
         ku = ku + ln
         ln = 2 * ln
      enddo
            
      return
      end

c---------------------------------------------------------------------
c---------------------------------------------------------------------
c---------------------------------------------------------------------
      integer function ilog2(n)
      implicit none
      integer n
c---------------------------------------------------------------------
c---------------------------------------------------------------------  
      integer nn, lg
      if (n .eq. 1) then
         ilog2=0
         return
      endif
      lg = 1
      nn = 2
      do while (nn .lt. n)
         nn = nn*2
         lg = lg+1
      end do
      ilog2 = lg
      return
      end
c---------------------------------------------------------------------
c---------------------------------------------------------------------
      subroutine CalculateChecksum(iterN,u,d1,d2,d3)
        implicit none
        include 'global.h'
        integer iterN
        integer d1,d2,d3
        double complex csum
        double complex u(d1+1,d2,d3)

        integer i, i1, ii, ji, ki
        csum = dcmplx (0.0, 0.0)

        if (iterN .eq. 1) sums = (0.0d0, 0.0d0)

        do i = 1, 1024
          i1 = i
          ii = mod (i1, d1) + 1
          ji = mod (3 * i1, d2) + 1
          ki = mod (5 * i1, d3) + 1
          csum = csum + u(ii,ji,ki)
        end do
        sums = sums + csum/dble(d1*d2*d3)

      return
      end

c---------------------------------------------------------------------
c---------------------------------------------------------------------
      subroutine evolve(x,y,twiddle,nx,ny,nz)
      double complex x(nx+1,ny,nz),y(nx+1,ny,nz)
      real*8 twiddle(nx+1,ny,nz)
      integer nx,ny,nz
      integer i,j,k
           do i = 1, nz
             do k = 1, ny
               do j = 1, nx
                   y(j,k,i)=y(j,k,i)*twiddle(j,k,i)
                   x(j,k,i)=y(j,k,i)
                 end do
              end do
           end do
      
      return
      end
c---------------------------------------------------------------------
c---------------------------------------------------------------------

c---------------------------------------------------------------------
      subroutine read_skip(ascii,u0_real,channel,n1,n2,n3)

      implicit none

      integer channel, n1, n2, n3, i, j, k, ascii, stat
      double precision u0_real(2,n1+1,n2,n3), ifac

c     read the real part of the double complex array 
      if (ascii .eq. 0) then
        read(channel,iostat=stat) 
     $      (((u0_real(1,i,j,k),i=1,n1),j=1,n2),k=1,n3)
      else
        read(channel,99,iostat=stat) 
     $      (((u0_real(1,i,j,k),i=1,n1),j=1,n2),k=1,n3)
99       format(500(e20.13))
      endif

      if     (stat .lt. 0) then
        print *, 'EOF encountered while reading ft input file'
        stop 566
      elseif (stat .gt. 0) then
        print *, 'Error encountered while reading ft input file'
        stop 567
      endif

c     set the imaginary part of the double complex array
      do k = 1, n3
        do j = 1, n2
          do i = 1, n1
            ifac = dfloat(mod(i+j+k,3)-1)
            u0_real(2,i,j,k) = ifac * dabs(u0_real(1,i,j,k))
          end do
        end do
      end do

      return
      end

      subroutine write_skip(ascii,u0_real,channel,n1,n2,n3)

      implicit none

      integer channel, n1, n2, n3, i, j, k, ascii, stat
      double precision u0_real(2,n1+1,n2,n3)
      double precision fac

C     NOTE: IN ORIGINAL NPBS THE INVERSE FFT DID NOT CONTAIN THE
C           MULTIPLICATION FACTOR 1/(N1*N2*N3). SINCE WE USE THE OUTPUT
C           OF ONE FT INVOCATION AS INPUT FOR ANOTHER, WE MUST APPLY THE
C           PROPER SCALING TO PREVENT THE BENCHMARK FROM BLOWING UP

      fac = 1.d0/dble(n1*n2*n3)

c     write the real part of the double complex array 
      if (ascii .eq. 0) then
        write(channel,iostat=stat) 
     $       (((u0_real(1,i,j,k)*fac,i=1,n1),j=1,n2),k=1,n3)
      else
        write(channel,99,iostat=stat) 
     $       (((u0_real(1,i,j,k)*fac,i=1,n1),j=1,n2),k=1,n3)
99      format(500(e20.13))
      endif

      if     (stat .lt. 0) then
        print *, 'EOF encountered while writing ft output file'
        stop 568
      elseif (stat .gt. 0) then
        print *, 'Error encountered while writing ft output file'
        stop 569
      endif

      return
      end


c=======================================================================
c      START OF UTILITY FUNCTIONS
c=======================================================================


       subroutine dump_solution(ascii, name, init_con, pid, pidlen,
     $                          u0,n1,n2,n3)

       implicit none 
       include 'global.h'

       integer init_con, pidlen, taillen, outfilelen, i, j, k, m, stat
       character name*2, outfile*100, tail*10, fileform*12
       character*(*) pid
       data taillen, outfilelen /10,100/
       integer n1, n2, n3, ascii
       double complex u0(n1+1,n2,n3)

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
         stop 570
       endif
       open(10,file=outfile,form=fileform,status='unknown',
     $      iostat=stat)
       if (stat .ne. 0) then
         print *, 'Failure: Could not open ft output file'
         stop 571
       else
         call write_skip(ascii,u0,10,n1,n2,n3) 
       endif

       return
       end

c---------------------------------------------------------------------
c---------------------------------------------------------------------


c---------------------------------------------------------------------
c---------------------------------------------------------------------
      subroutine compute_initial_conditions(u0,d1,d2,d3,ascii,
     $                       name,init_con, pid, pidlen)

c---------------------------------------------------------------------
c---------------------------------------------------------------------

c---------------------------------------------------------------------
c Initialize the solution using an input file
c---------------------------------------------------------------------
      implicit none

      include 'global.h'
      integer init_con, pidlen, taillen, infilelen, stat, ascii,
     $        d1, d2, d3, i, j, k
      character name*2, infile*100, tail*10, fileform*12
      character*(*) pid
      data taillen, infilelen /10,100/

      double complex u0(d1+1, d2, d3)
      
      if ((name .eq. 'VP') .or. (name .eq. 'MB')) then

c  construct the name of the input file and read it
        call blankout(infile, infilelen)
        call blankout(tail, taillen)
        infile = name
        call integer_to_string(tail, taillen, init_con)
        call join(infile,infilelen,tail,taillen)
        call join(infile,infilelen,pid,pidlen)
        call join(infile,infilelen,'IN',2)
        print *, 'File to be read is named:', infile
        if (ascii .eq. 0) then
          fileform = 'unformatted'
        elseif (ascii .eq. 1) then
          fileform = 'formatted'
        else
          print *, 'Failure: Illegal data format: ', ascii
          stop 572
        endif
        open(10,file=infile,form=fileform,status='old',
     $       iostat=stat)
        if (stat .ne. 0) then
          print *, 'Failure: Could not open ft input file'
          stop 573
        else
          call read_skip(ascii,u0,10,d1,d2,d3)
        endif
        return

      endif


      return
      end
