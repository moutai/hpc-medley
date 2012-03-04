      subroutine verify(d1, d2, d3, nt, verified, class, name,
     $                  col_indx, width, depth, init_con)

c---------------------------------------------------------------------
c---------------------------------------------------------------------

      implicit none
      include 'global.h'
      integer d1, d2, d3, nt, col_indx
      character class, name*2
      logical verified
      integer i, width, depth, init_con

      double precision vdata_real, norm_sum, norm_sum_tot
      double precision vdata_imag
      character*25     char_sum

      norm_sum_tot = 0.d0
      verified = .true.
c---------------------------------------------------------------------
c   DIVIDE "SUMS" BY NUMBER OF ITERATIONS TO OBTAIN AVERAGE CHECKSUM
c---------------------------------------------------------------------
      sums = sums/nt

      write (*, 30)  sums
 30   format (' Computed checksum  =',1P2D22.12)

      write(*, 2022)
 2022 format(' No reference values provided')

      if ((name .eq. 'MB') .or.
     $    (name .eq. 'VP' .and. init_con .eq. width*depth-1)) then

c---------------------------------------------------------------------
c       Compute the integer checksum
c---------------------------------------------------------------------         

        write (char_sum,99) dabs(dble(sums))
        read (char_sum(1:19),299) norm_sum
        norm_sum_tot = norm_sum_tot + norm_sum
        write (char_sum,99) dabs(dimag(sums))
        read (char_sum(1:19),299) norm_sum
        norm_sum_tot = norm_sum_tot + norm_sum

99      format(0Pd23.16)  
299     format(f19.16)

        write (*,499) norm_sum_tot
499     format('Normalized checksum ', f19.15)

      endif

      return
      end
