
c---------------------------------------------------------------------
c---------------------------------------------------------------------
      subroutine setiv(ascii, name, init_con, pid, pidlen, width)

c---------------------------------------------------------------------
c---------------------------------------------------------------------

c---------------------------------------------------------------------
c
c   set the initial values of independent variables based on tri-linear
c   interpolation of boundary values in the computational space.
c
c---------------------------------------------------------------------

      implicit none

      include 'applu.incl'

c---------------------------------------------------------------------
c  local variables
c---------------------------------------------------------------------
      integer i, j, k, m, init_con, pidlen, taillen, infilelen, ascii
      integer stat, width
      double precision  x, y, z, mx, my, mz
      character*(*) pid
      character name*2, infile*100, tail*10, fileform*12
      data taillen, infilelen /10,100/

c  decide whether to initialize from file, or by interpolation;
c  if from file, only do it if this is the real initialization, and
c  only if this is not the first node in the Helical Chain graph

       if ((name .eq. 'HC') .or. 
     $     (name .eq. 'MB' .and. (init_con .ge. width))) then

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
           stop 766
         endif
         open(10,file=infile,form=fileform,status='old',
     $        iostat=stat)
         if (stat .ne. 0) then
           print *, 'Failure: Could not read lu input file'
           stop 767
         elseif (ascii .eq. 0) then
           read (10,iostat=stat) 
     $          ((((u(m,i,j,k), m=1,5),i=1,nx),j=1,ny),k=1,nz)
         else
           read (10,99,iostat=stat) 
     $          ((((u(m,i,j,k), m=1,5),i=1,nx),j=1,ny),k=1,nz)
99         format(500(e20.13))
         endif
         if     (stat .lt. 0) then
           print *, 'EOF encountered while reading lu input file'
           stop 768
         elseif (stat .gt. 0) then
           print *, 'Error encountered while reading lu input file'
           stop 769
         endif

         return
       endif

      do k = 2, nz - 1
         z  = ( dble (k-1) ) / (nz-1)
         mz = 1.d0 - z
         do j = 2, ny - 1
            y  = ( dble (j-1) ) / (ny-1)
            my = 1.d0 - y
c            do i = 1, nx
            do i = 2, nx-1
               x  = ( dble (i-1) ) / (nx-1)
               mx = 1.d0 -x

               do m = 1, 5
                  u(m,i,j,k) = 
     >                  x*( y*(z*u(m,nx,ny,nz) + mz*u(m,nx,ny,1)) +
     >                     my*(z*u(m,nx,1,nz)  + mz*u(m,nx,1,1))) +
     >                  mx*(y*(z*u(m,1,ny,nz)  + mz*u(m,1,ny,1)) +
     >                     my*(z*u(m,1,1,nz)   + mz*u(m,1,1,1)))

               end do
            end do
         end do
      end do

      return
      end

