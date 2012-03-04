c
      include 'mpif.h'
c
      integer   max_zones
      parameter (max_zones=x_zones*y_zones)
      integer   proc_zone_id(max_zones), zone_proc_id(max_zones),
     &          proc_zone_count(num_procs), proc_zone_size(num_procs),
     &          proc_num_threads(num_procs), proc_num_zones,
     &          proc_group(num_procs)
      common /mpi_cmn1/ proc_zone_id, zone_proc_id, proc_zone_count,
     &          proc_zone_size, proc_num_threads, proc_num_zones,
     &          proc_group
c
      integer   myid, root, comm_setup, ierror, dp_type
      integer   num_threads, mz_bload, max_threads
      logical   active
      common /mpi_cmn2/ myid, root, comm_setup, ierror, active, 
     &          dp_type, num_threads, mz_bload, max_threads
