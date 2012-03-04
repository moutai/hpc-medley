
c---------------------------------------------------------------------
c---------------------------------------------------------------------

      subroutine read_input

c---------------------------------------------------------------------
c---------------------------------------------------------------------

      implicit none

      include 'header.h'

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

 1000 format(//,' NAS Parallel Benchmarks (NPB3.1-MZ-SER)',
     >          ' - LU Multi-Zone Serial Benchmark', /)
 1001 format(' Number of zones: ', i2, '  x  ',  i2)
 1002 format(' Iterations: ', i3, '    dt: ', F10.6/)

      return
      end


