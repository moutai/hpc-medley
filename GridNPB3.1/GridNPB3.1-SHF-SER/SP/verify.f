
c---------------------------------------------------------------------
c---------------------------------------------------------------------

        subroutine verify(no_time_steps, class, verified, name)

c---------------------------------------------------------------------
c---------------------------------------------------------------------

c---------------------------------------------------------------------
c  verification routine                         
c---------------------------------------------------------------------

        include 'header.h'

        double precision xce(5), xcr(5), dtref, norm_sum, norm_sum_tot
        integer          m, no_time_steps
        character        class, name*2, char_sum*25
        logical          verified

        norm_sum_tot = 0.d0
        verified = .true.

c---------------------------------------------------------------------
c   compute the error norm and the residual norm, and exit if not printing
c---------------------------------------------------------------------
        call error_norm(xce)
        call compute_rhs

        call rhs_norm(xcr)

        do m = 1, 5
           xcr(m) = xcr(m) / dt
        enddo

        write (*, 2005)
 2005   format(' RMS-norms of residual')
        do m = 1, 5
            write(*, 2015) m, xcr(m)
        end do
        write (*,2006)                      
 2006   format(' RMS-norms of solution error')
        do m = 1, 5
            write(*, 2015) m, xce(m)
        enddo
 2015   format('          ', i2, E20.13)

        write(*, 2022)
 2022   format(' No reference values provided')
        
        if (name .eq. 'ED') then

c---------------------------------------------------------------------
c         Compute the normalized checksum
c---------------------------------------------------------------------

          do m = 1, 5
           
            write (char_sum,99) dabs(xcr(m))
            read (char_sum(1:19),299) norm_sum
            norm_sum_tot = norm_sum_tot + norm_sum
            write (char_sum,99) dabs(xce(m))
            read (char_sum(1:19),299) norm_sum
            norm_sum_tot = norm_sum_tot + norm_sum
           
          enddo

99        format(0Pd23.16)  
299       format(f19.16)

          write (*,499) norm_sum_tot
499       format('Normalized checksum ', f19.15)

        endif

        return
        end
