         subroutine appft (niter, total_time, verified, width, depth,
     $                     ascii, class, verbose, init_con, col_indx, 
     $                     name, pid, pidlen)

         implicit none

         include  'global.h'
         integer niter, width, depth, init_con, col_indx, ascii, 
     $           pidlen, verbose
	 double precision total_time, mflops
         character name*2, class
         character*(*) pid
	 logical verified
!
! Local variables
!
         integer i, j, k, kt, n12, n22, n32, ii, jj, kk, ii2, ik2
         double precision ap
         double precision twiddle(nx+1,ny,nz)
        
         double complex xnt(nx+1,ny,nz),y(nx+1,ny,nz),
     &                  pad1(128),pad2(128)
         common /mainarrays/ xnt,pad1,y,pad2,twiddle

         double complex exp1(nx), exp2(ny), exp3(nz)

         do i=1,15
           call timer_clear(i)
	 end do         

         call timer_start(2)         

         call compute_initial_conditions(xnt,nx,ny,nz,ascii,
     $              name,init_con, pid, pidlen)
         
         call CompExp( nx, exp1 )
         call CompExp( ny, exp2 )
         call CompExp( nz, exp3 )           
         call fftXYZ(1,xnt,y,exp1,exp2,exp3,nx,ny,nz)
         call timer_stop(2)      

         call timer_start(1)
         if (timers_enabled) call timer_start(13)
	 
         n12 = nx/2
         n22 = ny/2
         n32 = nz/2
         ap = - 4.d0 * alpha * pi ** 2
         do i = 1, nz
	   ii = i-1-((i-1)/n32)*nz
	   ii2 = ii*ii
           do k = 1, ny
	     kk = k-1-((k-1)/n22)*ny
	     ik2 = ii2 + kk*kk
             do j = 1, nx
	         jj = j-1-((j-1)/n12)*nx
                 twiddle(j,k,i) = exp(ap*dble(jj*jj + ik2))
               end do
            end do
         end do
         if (timers_enabled) call timer_stop(13)      

         do kt = 1, niter
	   if (timers_enabled) call timer_start(11)      
	   call evolve(xnt,y,twiddle,nx,ny,nz)
           if (timers_enabled) call timer_stop(11)      
           if (timers_enabled) call timer_start(15)      
           call fftXYZ(-1,xnt,xnt,exp1,exp2,exp3,nx,ny,nz)
           if (timers_enabled) call timer_stop(15)      
           if (timers_enabled) call timer_start(10)      
           call CalculateChecksum(kt,xnt,nx,ny,nz)           
           if (timers_enabled) call timer_stop(10)      
         end do

!
! Verification test.
!
         if ((name .eq. 'MB') .or.
     $      (name .eq. 'VP' .and. init_con .eq. width*depth-1) .or.
     $      (verbose .eq. 1) ) then

           if (timers_enabled) call timer_start(14)      
           call verify(nx, ny, nz, niter, verified, class, name,
     $                 col_indx, width, depth, init_con)
           if (timers_enabled) call timer_stop(14)      
           call timer_stop(1)

           total_time = timer_read(1)

	   if (timers_enabled) then
             print*,'FT subroutine timers '    
             write(*,40) 'FT total                  ', timer_read(1)
             write(*,40) 'WarmUp time               ', timer_read(2)
             write(*,40) 'fftXYZ body               ', timer_read(3)
             write(*,40) 'Swarztrauber              ', timer_read(4)
             write(*,40) 'X time                    ', timer_read(7)
             write(*,40) 'Y time                    ', timer_read(8)
             write(*,40) 'Z time                    ', timer_read(9)
             write(*,40) 'CalculateChecksum         ', timer_read(10)
             write(*,40) 'evolve                    ', timer_read(11)
c         write(*,40) 'compute_initial_conditions', timer_read(12)
             write(*,40) 'twiddle                   ', timer_read(13)
             write(*,40) 'verify                    ', timer_read(14)
             write(*,40) 'fftXYZ                    ', timer_read(15)
             write(*,40) 'Benchmark time            ', total_time
   40        format(' ',A26,' =',F9.4)
           endif


           if( total_time .ne. 0. ) then
             mflops = 1.0d-6*float(ntotal) *
     >               (14.8157+7.19641*log(float(ntotal))
     >            +  (5.23518+7.21113*log(float(ntotal)))*niter)
     >                   /total_time
           else
             mflops = 0.0
           endif

           call print_results('FT', class, nx, ny, nz, niter,
     >       total_time, mflops, '          floating point', verified, 
     >       npbversion, compiletime, cs1, cs2, cs3, cs4, 
     >       cs5, cs6)
         endif

         if (name.eq.'VP' .and. (init_con.lt.width*depth-1)) then
           call dump_solution(ascii, name, init_con, pid, 
     $                        pidlen, xnt, nx, ny, nz)
         endif

       

         return
      end
