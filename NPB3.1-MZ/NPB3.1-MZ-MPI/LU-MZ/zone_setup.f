       subroutine zone_setup(nx, nxmax, ny, nz)

       include 'header.h'
       include 'mpi_stuff.h'

       integer nx(*), nxmax(*), ny(*), nz(*)

       integer           i,  j, zone_no
       double precision  x_r, y_r, x_smallest, y_smallest

       if (dabs(ratio-1.d0) .gt. 1.d-10) then

c        compute zone stretching only if the prescribed zone size ratio 
c        is substantially larger than unity       

         x_r   = dexp(dlog(ratio)/(x_zones-1))
         y_r   = dexp(dlog(ratio)/(y_zones-1))
         x_smallest = dble(gx_size)*(x_r-1.d0)/(x_r**x_zones-1.d0)
         y_smallest = dble(gy_size)*(y_r-1.d0)/(y_r**y_zones-1.d0)

c        compute tops of intervals, using a slightly tricked rounding
c        to make sure that the intervals are increasing monotonically
c        in size

         do i = 1, x_zones
            x_end(i) = x_smallest*(x_r**i-1.d0)/(x_r-1.d0)+0.45d0
         end do

         do j = 1, y_zones
            y_end(j) = y_smallest*(y_r**j-1.d0)/(y_r-1.d0)+0.45d0
         end do
 
       else

c        compute essentially equal sized zone dimensions

         do i = 1, x_zones
           x_end(i)   = (i*gx_size)/x_zones
         end do

         do j = 1, y_zones
           y_end(j)   = (j*gy_size)/y_zones
         end do

       endif

       x_start(1) = 1
       do i = 1, x_zones
          if (i .ne. x_zones) x_start(i+1) = x_end(i) + 1
          x_size(i)  = x_end(i) - x_start(i) + 1
       end do

       y_start(1) = 1
       do j = 1, y_zones
          if (j .ne. y_zones) y_start(j+1) = y_end(j) + 1
          y_size(j) = y_end(j) - y_start(j) + 1
       end do

       if (myid .eq. root) write (*,*) 'Zone sizes:'

       do j = 1, y_zones
         do i = 1, x_zones
           zone_no = (i-1)+(j-1)*x_zones+1
           nx(zone_no) = x_size(i)
           nxmax(zone_no) = nx(zone_no) + 1 - mod(nx(zone_no),2)
           ny(zone_no) = y_size(j)
           nz(zone_no) = gz_size

           if (myid .eq. root) write (*,99) zone_no, nx(zone_no), 
     $                  ny(zone_no), nz(zone_no)
         end do
       end do

 99    format(i4,':   ',i4,' x ',i4,' x ',i4)

       return
       end


       subroutine zone_starts(num_zones, nxmax, ny, nz, 
     &                        start1, start5, 
     $                        qstart_west,  qstart_east,
     $                        qstart_south, qstart_north)

       include 'header.h'
       include 'mpi_stuff.h'

       integer num_zones
       integer nxmax(*), ny(*), nz(*), start1(*), start5(*), 
     $         qstart_west(*), qstart_east(*), qstart_south(*), 
     $         qstart_north(*)

       integer zone, zone_size, iz
       integer x_face_size, y_face_size

       do iz = 1, proc_num_zones
      	 zone = proc_zone_id(iz)
         zone_size = nxmax(zone)*ny(zone)*nz(zone)
         x_face_size = (ny(zone)-2)*(nz(zone)-2)*5
         y_face_size = (nxmax(zone)-2)*(nz(zone)-2)*5           
         if (iz .eq. 1) then
           start1(iz)=1
           start5(iz)=1
           qstart_west(iz) = 1
         endif
         qstart_east(iz)  = qstart_west(iz) + x_face_size
         qstart_south(iz) = qstart_east(iz) + x_face_size
         qstart_north(iz) = qstart_south(iz)+ y_face_size
         if (iz .ne. proc_num_zones) then
           start1(iz+1) = start1(iz) + zone_size
           start5(iz+1) = start5(iz) + zone_size*5
           qstart_west(iz+1) = qstart_north(iz) + y_face_size
         endif
       enddo

c       if (myid .eq. root) then
c       do iz = 1, proc_num_zones
c      	 zone = proc_zone_id(iz)
c	 write(*,10) myid,iz,zone,start1(iz),start5(iz)
c       enddo
c   10  format(' myid',i4,' iz=',i4,' zone=',i4,' start1=',i7,
c     &        ' start5=',i7)
c       endif

       return
       end
