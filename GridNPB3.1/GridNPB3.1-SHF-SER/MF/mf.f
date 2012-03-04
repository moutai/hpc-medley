c this program reads a number of input grids from file, interpolates them
c onto a grid of specified dimensions, and writes a single output file.
c
c Usage:
c    grid_filter<<EOF
c      filetype
c      filename_out
c         nx_out  ny_out  nz_out
c      number_of_input_files
c      filename1_in
c         nx1_in ny1_in nz1_in
c      filename2_in
c         nx2_in ny2_in nz2_in
c      ........... 
c         ..... ..... .....
c      filenamen_in
c         nxn_in nyn_in nzn_in
c    EOF
c
c file type can be "v" or "s," for vector or scalar fields, respectively

       program grid_filter

       implicit none

c      insert header file that specifies SIZE
       include 'npbparams.h'

       integer  nxmax, nymax, nzmax, ng, i, n, stat, ascii, mult
       parameter (nxmax=SIZE, nymax=SIZE, nzmax=SIZE)
       integer nx_in, ny_in, nz_in, nx_out, ny_out, nz_out
       character filename_in*100, filename_out*100, fileform*12

       double precision  u_in (SIZE), u_out(SIZE)
       common /bigarray/ u_in,        u_out
       character filetype

       read *, ascii
       if (ascii .eq. 0) then
         fileform = 'unformatted'
       elseif (ascii .eq. 1) then
         fileform = 'formatted'
       else
         print *, 'Unknown file type in grid_filter: abort'
         stop 466
       endif

       read (*,99) filetype
 99    format (a)

       if     (filetype  .eq. 'v') then
         mult = 5
       elseif (filetype  .eq. 's') then
         mult = 1
       else
         print *, 'Illegal file type: ', filetype
         stop 467
       endif

       read (*,99) filename_out

       read  *, nx_out, ny_out, nz_out

       read *, ng
       
       if (ng .lt. 1) then 
         print *, 'Illegal number of input grids: ', ng
         stop 468
       endif

c initialize the output array

       do i = 1, mult*nx_out*ny_out*nz_out
           u_out(i) = 0.d0
       enddo

       do n = 1, ng

         read (*,99) filename_in

         open(10,file=filename_in, form=fileform, status='old', 
     $        iostat=stat)
         if (stat .ne. 0) then
           print *, 'Could not open file for input: ', filename_in
           stop 469
         endif

         read  *, nx_in, ny_in, nz_in
         if ((nx_in .lt. 2 .or. nx_in .gt. nxmax) .or.
     $       (ny_in .lt. 2 .or. ny_in .gt. nymax) .or.
     $       (nz_in .lt. 2 .or. nz_in .gt. nzmax)) then
            print *, 'Illegal input array dimension(s): ', 
     $                nx_in, ny_in, nz_in
            stop 470
         endif

c accumulate input arrays in the output array

         if (ascii .eq. 0) then
           read (10,iostat=stat) (u_in(i),i=1,mult*nx_in*ny_in*nz_in)
         else
           read (10,299,iostat=stat) 
     $          (u_in(i),i=1,mult*nx_in*ny_in*nz_in)
299        format(500(e20.13))
         endif
         if     (stat .lt. 0) then
           print *, 'EOF encountered while reading mf input file'
           stop 471
         elseif (stat .gt. 0) then
           print *, 'Error encountered while reading mf input file'
           stop 472
         endif

         if (filetype .eq. 'v') then
           call add_vector(u_in, nx_in, ny_in, nz_in,
     $                     u_out, nx_out, ny_out,nz_out)
         else 
           call add_scalar(u_in, nx_in, ny_in, nz_in,
     $                     u_out, nx_out, ny_out,nz_out)
         endif

         close(10)

       enddo

c compute average and write to file

       print *, 'Writing interpolated output file: ', filename_out

       open(11,file=filename_out, form=fileform, status='unknown', 
     $      iostat=stat)
       if (stat .ne. 0) then
         print *, 'Could not open file for output: ', filename_out
         stop 473
       endif

       if (ascii .eq. 0) then
         write (11,iostat=stat)
     $         (u_out(i)/ng,i=1,mult*nx_out*ny_out*nz_out)
       else
         write (11,199,iostat=stat) 
     $         (u_out(i)/ng,i=1,mult*nx_out*ny_out*nz_out)
199      format(500(e20.13))
       endif

       if     (stat .lt. 0) then
         print *, 'EOF encountered while writing mf output file'
         stop 474
       elseif (stat .gt. 0) then
         print *, 'Error encountered while writing mf output file'
         stop 475
       endif


       end

 
       subroutine add_vector(u1, nx1, ny1, nz1, u2, nx2, ny2, nz2)

       implicit none

       integer          nx1, ny1, nz1, nx2, ny2, nz2, iup, jup, kup,
     $                  ilow, jlow, klow, i2, j2, k2, m
       double precision u1(5,nx1,ny1,nz1), u2(5,nx2,ny2,nz2),
     $                  dx1, dy1, dz1, dx2, dy2, dz2, alpha, beta, 
     $                  gamma, ifloat, jfloat, kfloat

       dx1 = 1.d0/dfloat(nx1-1)
       dy1 = 1.d0/dfloat(ny1-1)
       dz1 = 1.d0/dfloat(nz1-1)
       dx2 = 1.d0/dfloat(nx2-1)
       dy2 = 1.d0/dfloat(ny2-1)
       dz2 = 1.d0/dfloat(nz2-1)

c check to see if any interpolation is required

       if ((nx1.eq.nx2) .and. (ny1.eq.ny2) .and. (nz1.eq.nz2)) then
         do k2 = 1, nz2
           do j2 = 1, ny2
             do i2 = 1, nx2
               do m = 1, 5
                 u2(m,i2,j2,k2) = u2(m,i2,j2,k2) + u1(m,i2,j2,k2)
               enddo
             enddo
           enddo
         enddo
       else

c        do the tri-linear interpolation
         do k2 = 1, nz2
           do j2 = 1, ny2
             do i2 = 1, nx2

c              determine the indices of the donor points for the interpolation
               kfloat = ((k2-1)*dz2*(nz1-1)+1)
               kup    = min(int(kfloat+1.d0),nz1)
               klow   = kup-1
               jfloat = ((j2-1)*dy2*(ny1-1)+1)
               jup    = min(int(jfloat+1.d0),ny1)
               jlow   = jup-1
               ifloat = ((i2-1)*dx2*(nx1-1)+1)
               iup    = min(int(ifloat+1.d0),nx1)
               ilow   = iup-1
               alpha  = ifloat-ilow
               beta   = jfloat-jlow
               gamma  = kfloat-klow

               do m = 1, 5

                 u2(m,i2,j2,k2) = u2(m,i2,j2,k2) + 
     $                       gamma*(
     $                           beta*(
     $                               alpha*       u1(m,iup,jup,kup)+
     $                               (1.d0-alpha)*u1(m,ilow,jup,kup)
     $                           ) +
     $                           (1.d0-beta)*(
     $                               alpha*       u1(m,iup,jlow,kup)+
     $                               (1.d0-alpha)*u1(m,ilow,jlow,kup)
     $                           ) ) + 
     $                       (1.d0-gamma)*(
     $                           beta*(
     $                               alpha*       u1(m,iup,jup,klow)+
     $                               (1.d0-alpha)*u1(m,ilow,jup,klow)
     $                           ) +
     $                           (1.d0-beta)*(
     $                               alpha*       u1(m,iup,jlow,klow)+
     $                               (1.d0-alpha)*u1(m,ilow,jlow,klow)
     $                           ) )

               enddo

             enddo
           enddo
         enddo

       endif
               
       return
       end


       subroutine add_scalar(u1,nx1,ny1,nz1,u2,nx2,ny2,nz2)

       implicit none

       integer          nx1,ny1,nz1,nx2,ny2,nz2, iup, jup, kup,
     $                  ilow, jlow, klow, i2, j2, k2
       double precision u1(nx1,ny1,nz1), u2(nx2,ny2,nz2),
     $                  dx1, dy1, dz1, dx2, dy2, dz2, alpha, beta, 
     $                  gamma, ifloat, jfloat, kfloat

       dx1 = 1.d0/dfloat(nx1-1)
       dy1 = 1.d0/dfloat(ny1-1)
       dz1 = 1.d0/dfloat(nz1-1)
       dx2 = 1.d0/dfloat(nx2-1)
       dy2 = 1.d0/dfloat(ny2-1)
       dz2 = 1.d0/dfloat(nz2-1)

c check to see if any interpolation is required

       if ((nx1.eq.nx2) .and. (ny1.eq.ny2) .and. (nz1.eq.nz2)) then
         do k2 = 1, nz2
           do j2 = 1, ny2
             do i2 = 1, nx2
               u2(i2,j2,k2) = u2(i2,j2,k2) + u1(i2,j2,k2)
             enddo
           enddo
         enddo
       else

c        do the tri-linear interpolation
         do k2 = 1, nz2
           do j2 = 1, ny2
             do i2 = 1, nx2

c              determine the indices of the donor points for the interpolation
               kfloat = ((k2-1)*dz2*(nz1-1)+1)
               kup    = min(int(kfloat+1.d0),nz1)
               klow   = kup-1
               jfloat = ((j2-1)*dy2*(ny1-1)+1)
               jup    = min(int(jfloat+1.d0),ny1)
               jlow   = jup-1
               ifloat = ((i2-1)*dx2*(nx1-1)+1)
               iup    = min(int(ifloat+1.d0),nx1)
               ilow   = iup-1
               alpha  = ifloat-ilow
               beta   = jfloat-jlow
               gamma  = kfloat-klow

               u2(i2,j2,k2) = u2(i2,j2,k2) + 
     $                     gamma*(
     $                         beta*(
     $                             alpha*       u1(iup,jup,kup)+
     $                             (1.d0-alpha)*u1(ilow,jup,kup)
     $                         ) +
     $                         (1.d0-beta)*(
     $                             alpha*       u1(iup,jlow,kup)+
     $                             (1.d0-alpha)*u1(ilow,jlow,kup)
     $                         ) ) + 
     $                     (1.d0-gamma)*(
     $                         beta*(
     $                             alpha*       u1(iup,jup,klow)+
     $                             (1.d0-alpha)*u1(ilow,jup,klow)
     $                         ) +
     $                         (1.d0-beta)*(
     $                             alpha*       u1(iup,jlow,klow)+
     $                             (1.d0-alpha)*u1(ilow,jlow,klow)
     $                         ) )

             enddo
           enddo
         enddo

       endif
               
       return
       end


