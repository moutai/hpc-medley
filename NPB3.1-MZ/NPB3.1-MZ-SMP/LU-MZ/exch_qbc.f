       subroutine exch_qbc(u, nx, nxmax, ny, nz, start5, qstart_west, 
     $                     qstart_east, qstart_south, qstart_north)

       include 'header.h'
       include 'smp_stuff.h'

       integer nx(*), nxmax(*), ny(*), nz(*), start5(*), izone, jzone,
     $         qstart_west(*),  qstart_east(*), qstart_south(*), 
     $         qstart_north(*), nnx, nnxmax, nny, nnz, zone_no, 
     $         id_west, id_east, id_south, id_north, izone_west, 
     $         izone_east, jzone_south, jzone_north, iz
       double precision u(*)

       if (timeron) call timer_start(t_rdis2)
       call smp_barrier
       if (timeron) call timer_stop(t_rdis2)

c      copy data to qbc buffer
       if (timeron) call timer_start(t_rdis1)
       do iz = 1, proc_num_zones
           zone_no = proc_zone_id(iz)
           nnx    = nx(zone_no)
           nnxmax = nxmax(zone_no)
           nny    = ny(zone_no)
           nnz    = nz(zone_no)

           call copy_x_face(u(start5(iz)),
     $                      qbc(qstart_west(zone_no)),
     $                      nnx, nnxmax, nny, nnz, 1, 'out')

           call copy_x_face(u(start5(iz)),
     $                      qbc(qstart_east(zone_no)),
     $                      nnx, nnxmax, nny, nnz, nnx-2, 'out')


           call copy_y_face(u(start5(iz)),
     $                      qbc(qstart_south(zone_no)),
     $                      nnx, nnxmax, nny, nnz, 1, 'out')

           call copy_y_face(u(start5(iz)),
     $                      qbc(qstart_north(zone_no)),
     $                      nnx, nnxmax, nny, nnz, nny-2, 'out')

       end do
       if (timeron) call timer_stop(t_rdis1)

       if (timeron) call timer_start(t_rdis2)
       call smp_barrier
       if (timeron) call timer_stop(t_rdis2)

c      copy data from qbc buffer
       if (timeron) call timer_start(t_rdis1)
       do iz = 1, proc_num_zones
           zone_no = proc_zone_id(iz)
           jzone  = (zone_no - 1)/x_zones + 1
           izone  = mod(zone_no - 1, x_zones) + 1
           nnx    = nx(zone_no)
           nnxmax = nxmax(zone_no)
           nny    = ny(zone_no)
           nnz    = nz(zone_no)
           izone_west  = mod(izone-2+x_zones,x_zones)+1
           izone_east  = mod(izone,           x_zones)+1
           jzone_south = mod(jzone-2+y_zones,y_zones)+1
           jzone_north = mod(jzone,           y_zones)+1
           id_west   = (izone_west-1)+(jzone-1)*x_zones+1
           id_east   = (izone_east-1)+(jzone-1)*x_zones+1
           id_south  = (izone-1)+(jzone_south-1)*x_zones+1
           id_north  = (izone-1)+(jzone_north-1)*x_zones+1

           call copy_x_face(u(start5(iz)),
     $                      qbc(qstart_east(id_west)),
     $                      nnx, nnxmax, nny, nnz, 0, 'in')

           call copy_x_face(u(start5(iz)),
     $                      qbc(qstart_west(id_east)),
     $                      nnx, nnxmax, nny, nnz, nnx-1, 'in')

           call copy_y_face(u(start5(iz)),
     $                      qbc(qstart_north(id_south)),
     $                      nnx, nnxmax, nny, nnz, 0, 'in')

           call copy_y_face(u(start5(iz)),
     $                      qbc(qstart_south(id_north)),
     $                      nnx, nnxmax, nny, nnz, nny-1, 'in')

       end do
       if (timeron) call timer_stop(t_rdis1)

       return
       end


       subroutine copy_y_face(u, qbc, nx, nxmax, ny, nz, jloc, dir)

       implicit         none

       integer          nx, nxmax, ny, nz, i, j, k, loc, jloc, m
       double precision u(5,0:nxmax-1,0:ny-1,0:nz-1), qbc(*)
       character        dir*(*)

       j = jloc
       loc = 1
       if (dir(1:2) .eq. 'in') then
!$OMP PARALLEL DEFAULT(SHARED) PRIVATE(m,i,k,loc)
!$OMP&  SHARED(j,nx,nz)
!$OMP DO
         do k = 1, nz-2
           loc=1+(k-1)*(nx-2)*5
           do i = 1, nx-2
             do m = 1, 5
               u(m,i,j,k) = qbc(loc) 
               loc = loc + 1
             end do
           end do
         end do
!$OMP END DO nowait
!$OMP END PARALLEL
       else if (dir(1:3) .eq. 'out') then
!$OMP PARALLEL DEFAULT(SHARED) PRIVATE(m,i,k,loc)
!$OMP&  SHARED(j,nx,nz)
!$OMP DO
         do k = 1, nz-2
           loc=1+(k-1)*(nx-2)*5
           do i = 1, nx-2
             do m = 1, 5
               qbc(loc) = u(m,i,j,k) 
               loc = loc + 1
             end do
           end do
         end do
!$OMP END DO nowait
!$OMP END PARALLEL
       else
         write (*,*) 'Erroneous data designation: ', dir
         stop
       endif

       return
       end


       subroutine copy_x_face(u, qbc, nx, nxmax, ny, nz, iloc, dir)

       implicit         none

       integer          nx, nxmax, ny, nz, i, j, k, loc, iloc, m
       double precision u(5,0:nxmax-1,0:ny-1,0:nz-1), qbc(*)
       character        dir*(*)

       i = iloc
       loc = 1
       if (dir(1:2) .eq. 'in') then
!$OMP PARALLEL DEFAULT(SHARED) PRIVATE(m,j,k,loc)
!$OMP&  SHARED(i,ny,nz)
!$OMP DO
         do k = 1, nz-2
           loc=1+(k-1)*(ny-2)*5
           do j = 1, ny-2
             do m = 1, 5
               u(m,i,j,k) = qbc(loc)
               loc = loc + 1
             end do
           end do
         end do
!$OMP END DO nowait
!$OMP END PARALLEL
       else if (dir(1:3) .eq. 'out') then
!$OMP PARALLEL DEFAULT(SHARED) PRIVATE(m,j,k,loc)
!$OMP&  SHARED(i,ny,nz)
!$OMP DO
         do k = 1, nz-2
           loc=1+(k-1)*(ny-2)*5
           do j = 1, ny-2
             do m = 1, 5
               qbc(loc) = u(m,i,j,k)
               loc = loc + 1
             end do
           end do
         end do
!$OMP END DO nowait
!$OMP END PARALLEL
       else
         write (*,*) 'Erroneous data designation: ', dir
         stop
       endif

       return
       end

