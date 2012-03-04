
c---------------------------------------------------------------------
c---------------------------------------------------------------------

        subroutine verify

c---------------------------------------------------------------------
c---------------------------------------------------------------------

c---------------------------------------------------------------------
c  verification routine                         
c---------------------------------------------------------------------

        include 'header.h'

        double precision xce(5), xcr(5)
        integer m


        call error_norm(xce)
        call compute_rhs

        call rhs_norm(xcr)

        do m = 1, 5
           xcr(m) = xcr(m) / dt
        enddo

        write (*,2005)
 2005   format(' RMS-norms of residual')

        do m = 1, 5
           write(*, 2015) m, xcr(m)
        enddo

        write (*,2006)
 2006   format(' RMS-norms of solution error')
        
        do m = 1, 5
           write(*, 2015) m, xce(m)
        enddo

 2015   format('          ', i2, E23.16)
        
        write(*, 2022)
 2022   format(' No reference values provided')

        return
        end
