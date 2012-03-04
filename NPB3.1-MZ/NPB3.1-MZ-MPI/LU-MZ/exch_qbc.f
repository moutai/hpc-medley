       subroutine exch_qbc(u, qbc_ou, qbc_in, nx, nxmax, ny, nz, 
     $                     start5, qstart_west, qstart_east, 
     $                     qstart_south, qstart_north)

       include 'header.h'
       include 'mpi_stuff.h'

       integer nx(*), nxmax(*), ny(*), nz(*), start5(*), izone, jzone,
     $         qstart_west(*),  qstart_east(*), qstart_south(*), 
     $         qstart_north(*), nnx, nnxmax, nny, nnz, zone_no, 
     $         id_west, id_east, id_south, id_north, izone_west, 
     $         izone_east, jzone_south, jzone_north, iz
       double precision u(*), qbc_ou(*), qbc_in(*)

       integer requests(8*max_numzones), nr, b_size1, b_size2, 
     $         statuses(MPI_STATUS_SIZE, 8*max_numzones)
       integer WEST, EAST, SOUTH, NORTH
       parameter (WEST=10000, EAST=20000, SOUTH=30000, NORTH=40000)


c      copy data to qbc buffer
       if (timeron) call timer_start(t_rdis1)
       do iz = 1, proc_num_zones
           zone_no = proc_zone_id(iz)
           nnx    = nx(zone_no)
           nnxmax = nxmax(zone_no)
           nny    = ny(zone_no)
           nnz    = nz(zone_no)

           call copy_x_face(u(start5(iz)),
     $                      qbc_ou(qstart_west(iz)),
     $                      nnx, nnxmax, nny, nnz, 1, 'out')

           call copy_x_face(u(start5(iz)),
     $                      qbc_ou(qstart_east(iz)),
     $                      nnx, nnxmax, nny, nnz, nnx-2, 'out')


           call copy_y_face(u(start5(iz)),
     $                      qbc_ou(qstart_south(iz)),
     $                      nnx, nnxmax, nny, nnz, 1, 'out')

           call copy_y_face(u(start5(iz)),
     $                      qbc_ou(qstart_north(iz)),
     $                      nnx, nnxmax, nny, nnz, nny-2, 'out')

       end do
       if (timeron) call timer_stop(t_rdis1)


c      exchange qbc buffers
       if (timeron) call timer_start(t_rdis2)
       nr = 0
       do iz = 1, proc_num_zones
           zone_no = proc_zone_id(iz)
           nnx    = nx(zone_no)
           nny    = ny(zone_no)
           nnz    = nz(zone_no)
	   b_size1= (nny-2)*(nnz-2)*5
	   b_size2= (nnx-2)*(nnz-2)*5
           jzone  = (zone_no - 1)/x_zones + 1
           izone  = mod(zone_no - 1, x_zones) + 1
           izone_west  = mod(izone-2+x_zones,x_zones)+1
           izone_east  = mod(izone,          x_zones)+1
           jzone_south = mod(jzone-2+y_zones,y_zones)+1
           jzone_north = mod(jzone,          y_zones)+1
           id_west   = (izone_west-1)+(jzone-1)*x_zones+1
           id_east   = (izone_east-1)+(jzone-1)*x_zones+1
           id_south  = (izone-1)+(jzone_south-1)*x_zones+1
           id_north  = (izone-1)+(jzone_north-1)*x_zones+1

      	   if (zone_proc_id(id_west) .ge. 0) then
c             receive qbc_east from id_west
      	      call mpi_irecv(qbc_in(qstart_west(iz)), b_size1, 
     >           dp_type, zone_proc_id(id_west), WEST+id_west,  
     >           comm_setup, requests(nr+1), ierror)
c             send qbc_west to id_west
      	      call mpi_isend(qbc_ou(qstart_west(iz)), b_size1, 
     >           dp_type, zone_proc_id(id_west), EAST+zone_no,  
     >           comm_setup, requests(nr+2), ierror)
      	      nr = nr + 2
      	   endif

      	   if (zone_proc_id(id_east) .ge. 0) then
c             receive qbc_west from id_east
      	      call mpi_irecv(qbc_in(qstart_east(iz)), b_size1, 
     >           dp_type, zone_proc_id(id_east), EAST+id_east,  
     >           comm_setup, requests(nr+1), ierror)
c             send qbc_east to id_east
      	      call mpi_isend(qbc_ou(qstart_east(iz)), b_size1, 
     >           dp_type, zone_proc_id(id_east), WEST+zone_no,  
     >           comm_setup, requests(nr+2), ierror)
      	      nr = nr + 2
      	   endif

      	   if (zone_proc_id(id_south) .ge. 0) then
c             receive qbc_north from id_south
      	      call mpi_irecv(qbc_in(qstart_south(iz)), b_size2, 
     >           dp_type, zone_proc_id(id_south), SOUTH+id_south,  
     >           comm_setup, requests(nr+1), ierror)
c             send qbc_south to id_south
      	      call mpi_isend(qbc_ou(qstart_south(iz)), b_size2, 
     >           dp_type, zone_proc_id(id_south), NORTH+zone_no,  
     >           comm_setup, requests(nr+2), ierror)
      	      nr = nr + 2
      	   endif

      	   if (zone_proc_id(id_north) .ge. 0) then
c             receive qbc_south from id_north
      	      call mpi_irecv(qbc_in(qstart_north(iz)), b_size2, 
     >           dp_type, zone_proc_id(id_north), NORTH+id_north,  
     >           comm_setup, requests(nr+1), ierror)
c             send qbc_north to id_north
      	      call mpi_isend(qbc_ou(qstart_north(iz)), b_size2, 
     >           dp_type, zone_proc_id(id_north), SOUTH+zone_no,  
     >           comm_setup, requests(nr+2), ierror)
      	      nr = nr + 2
      	   endif

       end do

       if (nr .gt. 0) then
           call mpi_waitall(nr, requests, statuses, ierror)
       endif
       if (timeron) call timer_stop(t_rdis2)


c      copy data from qbc buffer
       if (timeron) call timer_start(t_rdis1)
       do iz = 1, proc_num_zones
           zone_no = proc_zone_id(iz)
           nnx    = nx(zone_no)
           nnxmax = nxmax(zone_no)
           nny    = ny(zone_no)
           nnz    = nz(zone_no)
           jzone  = (zone_no - 1)/x_zones + 1
           izone  = mod(zone_no - 1, x_zones) + 1
           izone_west  = mod(izone-2+x_zones,x_zones)+1
           izone_east  = mod(izone,          x_zones)+1
           jzone_south = mod(jzone-2+y_zones,y_zones)+1
           jzone_north = mod(jzone,          y_zones)+1
           id_west   = (izone_west-1)+(jzone-1)*x_zones+1
           id_east   = (izone_east-1)+(jzone-1)*x_zones+1
           id_south  = (izone-1)+(jzone_south-1)*x_zones+1
           id_north  = (izone-1)+(jzone_north-1)*x_zones+1

      	   if (zone_proc_id(id_west) .ge. 0) then
               call copy_x_face(u(start5(iz)),
     $                      qbc_in(qstart_west(iz)),
     $                      nnx, nnxmax, nny, nnz, 0, 'in')
      	   else
               izone_west = -zone_proc_id(id_west)
               call copy_x_face(u(start5(iz)),
     $                      qbc_ou(qstart_east(izone_west)),
     $                      nnx, nnxmax, nny, nnz, 0, 'in')
      	   endif

      	   if (zone_proc_id(id_east) .ge. 0) then
               call copy_x_face(u(start5(iz)),
     $                      qbc_in(qstart_east(iz)),
     $                      nnx, nnxmax, nny, nnz, nnx-1, 'in')
      	   else
               izone_east = -zone_proc_id(id_east)
               call copy_x_face(u(start5(iz)),
     $                      qbc_ou(qstart_west(izone_east)),
     $                      nnx, nnxmax, nny, nnz, nnx-1, 'in')
      	   endif

      	   if (zone_proc_id(id_south) .ge. 0) then
               call copy_y_face(u(start5(iz)),
     $                      qbc_in(qstart_south(iz)),
     $                      nnx, nnxmax, nny, nnz, 0, 'in')
      	   else
               jzone_south = -zone_proc_id(id_south)
               call copy_y_face(u(start5(iz)),
     $                      qbc_ou(qstart_north(jzone_south)),
     $                      nnx, nnxmax, nny, nnz, 0, 'in')
      	   endif

      	   if (zone_proc_id(id_north) .ge. 0) then
               call copy_y_face(u(start5(iz)),
     $                      qbc_in(qstart_north(iz)),
     $                      nnx, nnxmax, nny, nnz, nny-1, 'in')
      	   else
               jzone_north = -zone_proc_id(id_north)
               call copy_y_face(u(start5(iz)),
     $                      qbc_ou(qstart_south(jzone_north)),
     $                      nnx, nnxmax, nny, nnz, nny-1, 'in')
      	   endif

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

