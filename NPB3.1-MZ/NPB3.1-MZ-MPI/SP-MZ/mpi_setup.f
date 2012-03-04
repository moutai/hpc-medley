c>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>c
c
      subroutine mpi_setup(num_zones, nx, ny, nz)
c
c  Set up MPI stuff, including
c     - define the active set of processes
c     - set up new communicator
c
      include 'header.h'
c
      integer num_zones, nx(*), ny(*), nz(*)
c
      include 'mpi_stuff.h'
c
      integer no_nodes, color
c
c ... initialize MPI parameters
      call mpi_init(ierror)
      
      call mpi_comm_size(MPI_COMM_WORLD, no_nodes, ierror)
      call mpi_comm_rank(MPI_COMM_WORLD, myid, ierror)

      if (.not. convertdouble) then
         dp_type = MPI_DOUBLE_PRECISION
      else
         dp_type = MPI_REAL
      endif
      
c---------------------------------------------------------------------
c     let node 0 be the root for the group (there is only one)
c---------------------------------------------------------------------
      root = 0
c
      if (no_nodes .lt. num_procs) then
      	 if (myid .eq. root) write(*, 10) no_nodes, num_procs
   10    format(' Requested MPI processes ',i5,
     &          ' less than the compiled value ',i5)
      	 call mpi_abort(MPI_COMM_WORLD, ierror)
	 stop
      endif
c
      if (myid .ge. num_procs) then
         active = .false.
         color = 1
      else
         active = .true.
         color = 0
      end if
      
      call mpi_comm_split(MPI_COMM_WORLD,color,myid,comm_setup,ierror)
      if (.not. active) return

      call mpi_comm_rank(comm_setup, myid, ierror)
      if (no_nodes .ne. num_procs) then
      	 if (myid .eq. root) write(*, 20) no_nodes, num_procs
   20 	 format('Warning: Requested ',i5,' MPI processes, ',
     &          'but the compiled value is ',i5/
     &          'The compiled value is used for benchmarking')
      endif
c
      return
      end
c
c>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>c
c
      subroutine env_setup(tot_threads)
c
c  Set up from environment variables
c
c ... common variables
      include 'header.h'
c
      integer tot_threads
c
      include 'mpi_stuff.h'
c
c ... local variables
      integer ios, curr_threads, ip, mp, group
      integer entry_counts(num_procs)
      character envstr*80
c
c$    integer omp_get_max_threads
c$    external omp_get_max_threads
c
      if (myid .ne. root) goto 80
c
c ... test the OpenMP multi-threading environment
      mp = 0
c$    mp = omp_get_max_threads()
c
c ... master sets up parameters
      call getenv('OMP_NUM_THREADS', envstr)
      if (envstr .ne. ' ' .and. mp .gt. 0) then
      	 read(envstr,*,iostat=ios) num_threads
	 if (ios.ne.0 .or. num_threads.lt.1) num_threads = 1
      	 if (mp .ne. num_threads) then
      	    write(*, 10) num_threads, mp
   10       format(' Warning: Requested ',i4,' threads per process,',
     &             ' but the active value is ',i4)
	    num_threads = mp
      	 endif
      else
      	 num_threads = 1
      endif
c
      call getenv('NPB_MZ_BLOAD', envstr)
      if (envstr .ne. ' ') then
      	 if (envstr.eq.'on' .or. envstr.eq.'ON') then
	    mz_bload = 1
	 else if (envstr(1:1).eq.'t' .or. envstr(1:1).eq.'T') then
	    mz_bload = 1
	 else
      	    read(envstr,*,iostat=ios) mz_bload
	    if (ios.ne.0) mz_bload = 0
	 endif
      else
      	 mz_bload = 1
      endif
c
      call getenv('NPB_MAX_THREADS', envstr)
      max_threads = 0
      if (mz_bload.gt.0 .and. envstr.ne.' ') then
      	 read(envstr,*,iostat=ios) max_threads
	 if (ios.ne.0 .or. max_threads.lt.0) max_threads = 0
	 if (max_threads.gt.0 .and. max_threads.lt.num_threads) then
	    write(*,20) max_threads, num_threads
   20       format(' Error: max_threads ',i5,
     &             ' is less than num_threads ',i5/
     &             ' Please redefine the value for NPB_MAX_THREADS',
     &             ' or OMP_NUM_THREADS')
      	    call mpi_abort(MPI_COMM_WORLD, ierror)
      	    stop
	 endif
      endif
c
      do ip = 1, num_procs
      	 proc_num_threads(ip) = num_threads
      	 proc_group(ip) = 0
      end do
c
      if (mp .le. 0) goto 80
c
      open(2, file='loadsp-mz.data', status='old', iostat=ios)
      if (ios.eq.0) then
      	 write(*,*) 'Reading load factors from loadsp-mz.data'

	 if (mz_bload .ge. 1) then
	    mz_bload = -mz_bload
	 endif

      	 do ip = 1, num_procs
      	    entry_counts(ip) = 0
      	 end do

      	 do while (.true.)
      	    read(2,*,end=40,err=40) ip, curr_threads, group
            if (mz_bload .lt. 0 .and. group .gt. 0) then
               mz_bload = -mz_bload
            endif
	    if (ip.ge.0 .and. ip.lt.num_procs) then
	       if (curr_threads .lt. 1) curr_threads = 1
	       ip = ip + 1
	       proc_num_threads(ip) = curr_threads
	       proc_group(ip) = group
	       entry_counts(ip) = entry_counts(ip) + 1
      	       write(*,30) ip-1, curr_threads, group
   30          format('  proc',i5,'  num_threads =',i4,
     >                '  group =',i4)
	    endif
	 end do
   40    close(2)

      	 do ip = 1, num_procs
	    if (entry_counts(ip) .eq. 0) then
	       write(*,*) '*** Error: Missing entry for proc ',ip-1
	       call mpi_abort(MPI_COMM_WORLD, ierror)
	       stop
	    else if (entry_counts(ip) .gt. 1) then
	       write(*,*) '*** Warning: Multiple entries for proc ',
     &                    ip-1, ', only the last one used'
	    endif
      	 end do

      else
      	 write(*,*) 'Use the default load factors with threads'
	 do ip = 1, num_procs
      	    write(*,30) ip-1, proc_num_threads(ip), proc_group(ip)
	 end do
      endif
c
c ... broadcast parameters to all processes
   80 call mpi_bcast(num_threads, 1, mpi_integer, root, 
     &               comm_setup, ierror)
      call mpi_bcast(mz_bload, 1, mpi_integer, root, 
     &               comm_setup, ierror)
      call mpi_bcast(max_threads, 1, mpi_integer, root, 
     &               comm_setup, ierror)
      call mpi_bcast(proc_num_threads, num_procs, mpi_integer, root, 
     &               comm_setup, ierror)
      call mpi_bcast(proc_group, num_procs, mpi_integer, root, 
     &               comm_setup, ierror)
c
      tot_threads = 0
      do ip = 1, num_procs
	 tot_threads = tot_threads + proc_num_threads(ip)
      end do
      if (myid .eq. root) then
         if (mp .gt. 0) write(*, 1004) tot_threads
 1004    format(' Total number of threads: ', i6/)
      endif
c
      return
      end
c
c>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>c
c
      subroutine get_comm_index(zone, iproc, proc_zone_id, 
     &                          comm_index)
c
      include 'header.h'
c
c  Calculate the communication index of a zone within a processor group
c
      integer zone, iproc, proc_zone_id(*), comm_index
c
c     local variables
      integer izone, jzone, id_west, id_east, id_south, id_north, 
     $        izone_west, izone_east, jzone_south, jzone_north
c
      jzone  = (zone - 1)/x_zones + 1
      izone  = mod(zone - 1, x_zones) + 1
      izone_west  = mod(izone-2+x_zones,x_zones) + 1
      izone_east  = mod(izone,  	x_zones) + 1
      jzone_south = mod(jzone-2+y_zones,y_zones) + 1
      jzone_north = mod(jzone,  	y_zones) + 1
      id_west	= izone_west + (jzone-1)*x_zones
      id_east	= izone_east + (jzone-1)*x_zones
      id_south  = izone + (jzone_south-1)*x_zones
      id_north  = izone + (jzone_north-1)*x_zones
c
      comm_index = 0
      if (proc_zone_id(id_west) .eq. iproc)
     $   comm_index = comm_index + y_size(jzone)
      if (proc_zone_id(id_east) .eq. iproc)
     $   comm_index = comm_index + y_size(jzone)
      if (proc_zone_id(id_south) .eq. iproc)
     $   comm_index = comm_index + x_size(izone)
      if (proc_zone_id(id_north) .eq. iproc)
     $   comm_index = comm_index + x_size(izone)
c
      return
      end
c
c>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>c
c
      subroutine map_zones(num_zones, nx, ny, nz, tot_threads)
c
c  Perform zone-process mapping for load balance
c
      include 'header.h'
c
      integer num_zones, nx(*), ny(*), nz(*), tot_threads
c
      include 'mpi_stuff.h'
c
c     local variables
      integer zone_size(max_zones), z_order(max_zones)
      integer zone, iz, z2, mz, np, ip, zone_comm, comm_index
      integer tot_size, cur_size
      integer max_size, imx, inc
      double precision diff_ratio, ave_size
c
      integer group, ipg, tot_group_size, tot_group_threads
      integer proc_group_flag(num_procs)
c
c ... sort the zones in decending order
      tot_size = 0
      do iz = 1, num_zones
      	 zone_size(iz) = nx(iz)*ny(iz)*nz(iz)
	 z_order(iz) = iz
	 tot_size = tot_size + zone_size(iz)
      end do
      do iz = 1, num_zones-1
      	 cur_size = zone_size(z_order(iz))
	 mz = iz
      	 do z2 = iz+1, num_zones
	    if (cur_size.lt.zone_size(z_order(z2))) then
	       cur_size = zone_size(z_order(z2))
	       mz = z2
	    endif
	 end do
	 if (mz .ne. iz) then
	    z2 = z_order(iz)
	    z_order(iz) = z_order(mz)
	    z_order(mz) = z2
	 endif
      end do
c
c      if (myid .eq. root) then
c      write(*,10)
c   10 format(' Sorted zones:'/
c     &       ' seq. zone   nx   ny   nz   size')
c      do iz = 1, num_zones
c      	 z2 = z_order(iz)
c      	 write(*,15) iz,z2,nx(z2),ny(z2),nz(z2),zone_size(z2)
c      end do
c   15 format(i4,':',4(1x,i4),1x,i7)
c      endif
c
c ... use a simple bin-packing scheme to balance the load among processes
      do ip = 1, num_procs
      	 proc_zone_count(ip) = 0
	 proc_zone_size(ip) = 0
      end do
      do iz = 1, num_zones
	 proc_zone_id(iz) = -1
      end do

      iz = 1
      do while (iz .le. num_zones)
c
c  ...   the current most empty processor
	 np = 1
	 cur_size = proc_zone_size(1)
      	 do ip = 2, num_procs
	    if (cur_size.gt.proc_zone_size(ip)) then
	       np = ip
	       cur_size = proc_zone_size(ip)
	    endif
	 end do
	 ip = np - 1
c
c  ...   get a zone that has the largest communication index with
c        the current group and does not worsen the computation balance
	 mz = z_order(iz)
	 if (iz .lt. num_zones) then
	    call get_comm_index(mz, ip, proc_zone_id, 
     &                          zone_comm)
      	    do z2 = iz+1, num_zones
	       zone = z_order(z2)

	       diff_ratio = dble(zone_size(z_order(iz)) - 
     &                      zone_size(zone)) / zone_size(z_order(iz))
      	       if (diff_ratio .gt. 0.05D0) goto 120

	       if (proc_zone_id(zone) .lt. 0) then
	          call get_comm_index(zone, ip, proc_zone_id, 
     &                                comm_index)
	          if (comm_index .gt. zone_comm) then
	             mz = zone
		     zone_comm = comm_index
	          endif
	       endif
	    end do
	 endif
c
c  ...   assign the zone to the current processor group
  120    proc_zone_id(mz) = ip
	 proc_zone_size(np) = proc_zone_size(np) + zone_size(mz)
	 proc_zone_count(np) = proc_zone_count(np) + 1
c
c  ...   skip the previously assigned zones
      	 do while (iz.le.num_zones)
            if (proc_zone_id(z_order(iz)).lt.0) goto 130
      	    iz = iz + 1
	 end do
  130    continue
      end do
c
c ... move threads around if needed
      mz = 1
      if (tot_threads.eq.num_procs .or. mz_bload.lt.1) mz = 0
c
      if (mz .ne. 0) then
c
      	 do ipg = 1, num_procs
	    proc_group_flag(ipg) = 0
	 end do
c
	 ipg = 1
c
c ...    balance load within a processor group
  200    do while (ipg .le. num_procs)
	    if (proc_group_flag(ipg) .eq. 0) goto 210
	    ipg = ipg + 1
	 end do
  210    if (ipg .gt. num_procs) goto 300
c
	 group = proc_group(ipg)
	 tot_group_size = 0
	 tot_group_threads = 0
	 do ip = ipg, num_procs
	    if (proc_group(ip) .eq. group) then
	       proc_group_flag(ip) = 1
	       tot_group_size = tot_group_size + proc_zone_size(ip)
	       tot_group_threads = tot_group_threads + 
     &                             proc_num_threads(ip)
	    endif
	 end do
c
      	 ave_size = dble(tot_group_size)/tot_group_threads
c
c  ...   distribute size evenly among threads
      	 cur_size = 0
      	 do ip = 1, num_procs
	    if (proc_group(ip) .ne. group) goto 220
      	    proc_num_threads(ip) = proc_zone_size(ip) / ave_size
      	    if (proc_num_threads(ip) .lt. 1)
     &          proc_num_threads(ip) = 1
      	    if (max_threads .gt. 0 .and. 
     &          proc_num_threads(ip) .gt. max_threads) 
     &          proc_num_threads(ip) = max_threads
      	    cur_size = cur_size + proc_num_threads(ip)
  220 	 end do
      	 mz = tot_group_threads - cur_size
c
c  ...   take care of any remainers
	 inc = 1
	 if (mz .lt. 0) inc = -1
      	 do while (mz .ne. 0)
      	    max_size = 0
      	    imx = 0
      	    do ip = 1, num_procs
	       if (proc_group(ip) .ne. group) goto 230
               if (mz .gt. 0) then
                  cur_size = proc_zone_size(ip) / proc_num_threads(ip)
                  if (cur_size.gt.max_size .and. (max_threads.le.0
     & 	              .or. proc_num_threads(ip).lt.max_threads)) then
                     max_size = cur_size
                     imx = ip
     	          endif
     	       else if (proc_num_threads(ip) .gt. 1) then
                  cur_size = proc_zone_size(ip) / 
     &	             	     (proc_num_threads(ip)-1)
     	          if (max_size.eq.0 .or. cur_size.lt.max_size) then
     	             max_size = cur_size
     	             imx = ip
     	          endif
     	       endif
  230 	    end do
      	    proc_num_threads(imx) = proc_num_threads(imx) + inc
      	    mz = mz - inc
      	 end do
c
         goto 200
      endif
c
c ... print the mapping
  300 if (myid .eq. root) then
      	 write(*,20)
   20 	 format(' Zone-process mapping:'/
     &          ' proc nzones zone_size nthreads size_per_thread')
      	 do ip = 1, num_procs
      	    write(*,25) ip-1,proc_zone_count(ip),
     &            proc_zone_size(ip),proc_num_threads(ip),
     &	          proc_zone_size(ip)/proc_num_threads(ip)
	    do iz = 1, num_zones
	       if (proc_zone_id(iz) .eq. ip-1) then
	          write(*,30) iz, zone_size(iz)
	       endif
	    end do
      	 end do
   25 	 format(i4,2x,i5,3x,i8,3x,i4,5x,i8)
   30 	 format(3x,'zone ',i4,2x,i8)
c
      	 max_size = 0
      	 do ip = 1, num_procs
      	    cur_size = proc_zone_size(ip)/proc_num_threads(ip)
      	    if (cur_size.gt.max_size) max_size = cur_size
      	 end do
      	 write(*,40) dble(tot_size)/max_size
   40 	 format(/' Calculated speedup = ',f8.2/)
      endif
c
c ... reorganize list of zones for this process
      zone = 0
      do iz = 1, num_zones
      	 zone_proc_id(iz) = proc_zone_id(iz)
      	 if (proc_zone_id(iz) .eq. myid) then
	    zone = zone + 1
	    proc_zone_id(zone) = iz
c           negative number indicates a zone assigned to this process
c           this information is used in exch_qbc
	    zone_proc_id(iz) = -zone
	 endif
      end do
      proc_num_zones = zone
      if (zone .ne. proc_zone_count(myid+1)) then
      	 if (myid .eq. root)
     &	    write(*,*) 'Warning: ',myid, ': mis-matched zone counts -', 
     &           zone, proc_zone_count(myid+1)
      endif
c
c ... set number of threads for this process
c$    call omp_set_num_threads(proc_num_threads(myid+1))
c
c ... pin-to-node
c      call smp_pinit_thread(num_procs, myid, proc_num_threads)
c
      return
      end
