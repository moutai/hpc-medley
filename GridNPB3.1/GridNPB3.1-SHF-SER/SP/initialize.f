
c---------------------------------------------------------------------
c---------------------------------------------------------------------

       subroutine  initialize(ascii, name, init_con, width, pid, pidlen)

c---------------------------------------------------------------------
c---------------------------------------------------------------------

c---------------------------------------------------------------------
c This subroutine initializes the field variable u using 
c tri-linear interpolation of the boundary values     
c---------------------------------------------------------------------

       include 'header.h'
  
       integer i, j, k, m, ix, iy, iz, init_con, num, pidlen,
     $         taillen, infilelen, stat, ascii, im1, jm1, km1,
     $         width
       double precision  xi, eta, zeta, Pface(5,3,2), Pxi, Peta, 
     >                   Pzeta, temp(5), x, y, z, mx, my, mz
       character name*2, infile*100, tail*10, fileform*12
       character*(*) pid
       data taillen, infilelen /10,100/

c      for convenience, store last grid indices in scalars
       im1 = grid_points(1)-1
       jm1 = grid_points(2)-1
       km1 = grid_points(3)-1

       if ((name .eq. 'HC') .or. 
     $     (name .eq. 'MB' .and. init_con .ge. width))  then
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
           stop 666
         endif
         open(10,file=infile,form=fileform,status='old',
     $          iostat=stat)
         if (stat .ne. 0) then
           print *, 'Failure: Could not read sp input file'
           stop 667
         elseif (ascii .eq. 0) then
           read (10,iostat=stat) 
     $          ((((u(m,i,j,k), m=1,5),i=0,im1),j=0,jm1),k=0,km1)
         else
           read (10,99,iostat=stat) 
     $          ((((u(m,i,j,k), m=1,5),i=0,im1),j=0,jm1),k=0,km1)
99       format(500(e20.13))
         endif
         if     (stat .lt. 0) then
           print *, 'EOF encountered while reading sp input file'
           stop 668
         elseif (stat .gt. 0) then
           print *, 'Error encountered while reading sp input file'
           stop 669
         endif

         return
       endif

    
c---------------------------------------------------------------------
c  Later (in compute_rhs) we compute 1/u for every element. A few of 
c  the corner elements are not used, but it convenient (and faster) 
c  to compute the whole thing with a simple loop. Make sure those 
c  values are nonzero by initializing the whole thing here. 
c---------------------------------------------------------------------
      do k = 0, grid_points(3)-1
         do j = 0, grid_points(2)-1
            do i = 0, grid_points(1)-1
               u(1,i,j,k) = 1.0
               u(2,i,j,k) = 0.0
               u(3,i,j,k) = 0.0
               u(4,i,j,k) = 0.0
               u(5,i,j,k) = 1.0
            end do
         end do
      end do

c---------------------------------------------------------------------
c first store the exact values on the boundaries
c---------------------------------------------------------------------

c---------------------------------------------------------------------
c west face                                                  
c---------------------------------------------------------------------

       x = 0.0d0
       i  = 0
       do  k = 0, km1
          z = dble(k) * dnzm1
          do   j = 0, jm1
             y = dble(j) * dnym1
             call exact_solution(x, y, z, temp)
             do   m = 1, 5
                u(m,i,j,k) = temp(m)
             end do
          end do
       end do

c---------------------------------------------------------------------
c east face                                                      
c---------------------------------------------------------------------

       x = 1.0d0
       i  = im1
       do   k = 0, km1
          z = dble(k) * dnzm1
          do   j = 0, jm1
             y = dble(j) * dnym1
             call exact_solution(x, y, z, temp)
             do   m = 1, 5
                u(m,i,j,k) = temp(m)
             end do
          end do
       end do

c---------------------------------------------------------------------
c south face                                                 
c---------------------------------------------------------------------

       y = 0.0d0
       j   = 0
       do  k = 0, km1
          z = dble(k) * dnzm1
          do   i = 0, im1
             x = dble(i) * dnxm1
             call exact_solution(x, y, z, temp)
             do   m = 1, 5
                u(m,i,j,k) = temp(m)
             end do
          end do
       end do


c---------------------------------------------------------------------
c north face                                    
c---------------------------------------------------------------------

       y = 1.0d0
       j   = jm1
       do   k = 0, km1
          z = dble(k) * dnzm1
          do   i = 0, im1
             x = dble(i) * dnxm1
             call exact_solution(x, y, z, temp)
             do   m = 1, 5
                u(m,i,j,k) = temp(m)
             end do
          end do
       end do

c---------------------------------------------------------------------
c bottom face                                       
c---------------------------------------------------------------------

       z = 0.0d0
       k    = 0
       do   i =0, im1
          x = dble(i) *dnxm1
          do   j = 0, jm1
             y = dble(j) * dnym1
             call exact_solution(x, y, z, temp)
             do   m = 1, 5
                u(m,i,j,k) = temp(m)
             end do
          end do
       end do

c---------------------------------------------------------------------
c top face     
c---------------------------------------------------------------------

       z = 1.0d0
       k    = km1
       do   i =0, im1
          x = dble(i) * dnxm1
          do   j = 0, jm1
             y = dble(j) * dnym1
             call exact_solution(x, y, z, temp)
             do   m = 1, 5
                u(m,i,j,k) = temp(m)
             end do
          end do
       end do


c---------------------------------------------------------------------
c next store the interpolated values everywhere on the grid    
c---------------------------------------------------------------------

c NEW VERSION TRI-LINEAR INTERPOLATION

       do  k = 1, grid_points(3)-2
         z  = dble(k) * dnzm1
         mz = 1.d0-z
         do  j = 1, grid_points(2)-2
           y  = dble(j) * dnym1
           my = 1.d0-y
           do   i = 1, grid_points(1)-2
             x  = dble(i) * dnxm1
             mx = 1.d0-x
               
             do   m = 1, 5

               u(m,i,j,k) = 
     >                  x*( y*(z*u(m,im1,jm1,km1)+ mz*u(m,im1,jm1,0)) +
     >                     my*(z*u(m,im1,0,km1)  + mz*u(m,im1,0,0))) +
     >                  mx*(y*(z*u(m,0,jm1,km1)  + mz*u(m,0,jm1,0)) +
     >                     my*(z*u(m,0,0,km1)    + mz*u(m,0,0,0)))

             end do
           end do
         end do
       end do

       return
       end


       subroutine lhsinit(size)

       include 'header.h'
       
       integer i, n, size

       i = size
c---------------------------------------------------------------------
c     zap the whole left hand side for starters
c---------------------------------------------------------------------
       do   n = 1, 5
          lhs (n,0) = 0.0d0
          lhsp(n,0) = 0.0d0
          lhsm(n,0) = 0.0d0
          lhs (n,i) = 0.0d0
          lhsp(n,i) = 0.0d0
          lhsm(n,i) = 0.0d0
       end do

c---------------------------------------------------------------------
c      next, set all diagonal values to 1. This is overkill, but 
c      convenient
c---------------------------------------------------------------------
       lhs (3,0) = 1.0d0
       lhsp(3,0) = 1.0d0
       lhsm(3,0) = 1.0d0
       lhs (3,i) = 1.0d0
       lhsp(3,i) = 1.0d0
       lhsm(3,i) = 1.0d0
 
       return
       end

