c
      include 'smp_libf.h'
c
      integer   max_zones
      parameter (max_zones=x_zones*y_zones)
      integer   proc_zone_id(max_zones),
     &          proc_zone_count(num_procs), proc_zone_size(num_procs),
     &          proc_num_threads(num_procs), proc_num_zones,
     &          proc_group(num_procs)
      common /smp_cmn1/ proc_zone_id, proc_zone_count, proc_zone_size, 
     &                  proc_num_threads, proc_num_zones, proc_group
c
      integer          myid, root, num_threads, mz_bload, max_threads
      common /smp_cmn2/ myid, root, num_threads, mz_bload, max_threads
c
      double precision qbc(1), sbuffer(15,0:0)
      pointer          (qbc_ptr, qbc)
      pointer          (sbuff_ptr, sbuffer)
      common /smp_cmn3/ qbc_ptr, sbuff_ptr
