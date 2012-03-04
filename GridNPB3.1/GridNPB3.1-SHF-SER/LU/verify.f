
c---------------------------------------------------------------------
c---------------------------------------------------------------------

        subroutine verify(xcr, xce, xci, class, verified, name,
     $                     width, depth, init_con)

c---------------------------------------------------------------------
c---------------------------------------------------------------------

c---------------------------------------------------------------------
c  verification routine                         
c---------------------------------------------------------------------

        implicit none
        include 'applu.incl'

        double precision xcr(5), xce(5), xci, norm_sum, norm_sum_tot
        integer          m, width, depth, init_con
        character        class, name*2, char_sum*25
        logical          verified
        norm_sum_tot = 0.d0
        verified = .true.

        write (*,2005)
 2005   format(' RMS-norms of residual')
        do m = 1, 5
          write(*, 2015) m, xcr(m)
        enddo
 2015   format('          ', i2, 2x, E20.13)

        write (*,2006)
 2006   format(' RMS-norms of solution error')
        do m = 1, 5
           write(*, 2015) m, xce(m)
        enddo

        write (*,2026)
 2026   format(' Surface integral')
        write(*, 2030) xci
 2030   format('          ', 4x, E20.13)

        write(*, 2022)
 2022   format(' No reference values provided')

        if (name .eq. 'HC' .and. init_con .eq. width*depth-1) then

c---------------------------------------------------------------------
c         Compute the integer checksum
c---------------------------------------------------------------------
          do m = 1, 5
           
            write (char_sum,99) dabs(xcr(m))
            read (char_sum(1:19),299) norm_sum
            norm_sum_tot = norm_sum_tot + norm_sum
            write (char_sum,99) dabs(xce(m))
            read (char_sum(1:19),299) norm_sum
            norm_sum_tot = norm_sum_tot + norm_sum

          enddo

          write (char_sum,99) dabs(xci)
          read (char_sum(1:19),299) norm_sum
          norm_sum_tot = norm_sum_tot + norm_sum

99        format(0Pd23.16)  
299       format(f19.16)

          write (*,499) norm_sum_tot
499       format('Normalized checksum ', f19.15)

        endif

        return
        end
