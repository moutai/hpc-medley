
c---------------------------------------------------------------------
c---------------------------------------------------------------------

      subroutine read_input(tot_threads)

c---------------------------------------------------------------------
c---------------------------------------------------------------------

      implicit none
      integer tot_threads

      include 'header.h'
      include 'smp_stuff.h'

      integer fstatus

      write(*, 1000) 
      open (unit=2,file='inputlu-mz.data',status='old',
     >      access='sequential',form='formatted', iostat=fstatus)
      if (fstatus .eq. 0) then

         write(*,*) 'Reading from input file inputlu-mz.data'

         read (2,*)
         read (2,*)
         read (2,*) ipr, inorm
         read (2,*)
         read (2,*)
         read (2,*) itmax
         read (2,*)
         read (2,*)
         read (2,*) dt
         read (2,*)
         read (2,*)
         read (2,*) omega
         read (2,*)
         read (2,*)
         read (2,*) tolrsd(1),tolrsd(2),tolrsd(3),tolrsd(4),tolrsd(5)
         close(2)
      else
         ipr   = ipr_default
         inorm = inorm_default
         itmax = itmax_default
         dt    = dt_default
         omega = omega_default
         tolrsd(1) = tolrsd1_def
         tolrsd(2) = tolrsd2_def
         tolrsd(3) = tolrsd3_def
         tolrsd(4) = tolrsd4_def
         tolrsd(5) = tolrsd5_def
      endif

      write(*, 1001) x_zones, y_zones
      write(*, 1002) itmax, dt
      write(*, 1003) num_procs

 1000 format(//,' NAS Parallel Benchmarks (NPB3.1-MZ-SMP)',
     >          ' - LU-MZ SMP+OpenMP Benchmark', /)
 1001 format(' Number of zones: ', i2, '  x  ',  i2)
 1002 format(' Iterations: ', i3, '    dt: ', F10.6)
 1003 format(' Number of active processes: ', i4/)

      call env_setup(tot_threads)

      return
      end


