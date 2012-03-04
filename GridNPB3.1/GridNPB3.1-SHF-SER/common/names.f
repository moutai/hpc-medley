c The following utility routine takes the last nine digits of a positive
c integer and stores them as a string

       subroutine integer_to_string(name, maxlen, number)

       implicit none
       integer maxlen, number, number2
       character name*(*)

c      won't support more than nine or maxlen digits
       number2 = mod(mod(number,1 000 000 000),10**maxlen)
         
       if (number2 .lt. 10) then
           write (name,11) number2
11         format(i1)
         elseif (number2 .lt. 100) then
           write (name,22) number2
22         format(i2)
         elseif (number2 .lt. 1000) then
           write (name,33) number2
33         format(i3)  
         elseif (number2 .lt. 10 000) then
           write (name,44) number2
44         format(i4)
         elseif (number2 .lt. 100 000) then
           write (name,55) number2
55         format(i5)
         elseif (number2 .lt. 1 000 000) then
           write (name,66) number2
66         format(i6)  
         elseif (number2 .lt. 10 000 000) then
           write (name,77) number2
77         format(i7)
         elseif (number2 .lt. 100 000 000) then
           write (name,88) number2
88         format(i8)  
         else
           write (name,99) number2
99         format(i9)
         endif

         return
         end

c The following utility routine takes two character strings, a head
c and a tail, and appends the head to the tail, removing any leading
c or embedded blanks from the tail.

         subroutine join(head, headlen, tail, taillen)

         implicit none

         integer headlen, taillen, ihead, itail, i
         character*(*) head, tail
         character*128 compact

         ihead = 0

c        skip to the end of the head, which is the first white space
         do i = 1, headlen
           if ((head(i:i) .eq. ' ') .and. (ihead .eq. 0)) ihead = i
         end do

c        if there are no blanks in the head string, there is no space
c        to append anything
         if (ihead .eq. 0) return

c        compact the tail string, but chop at 128 characters
         itail = 0
         do i = 1, taillen
           if ((tail(i:i) .ne. ' ') .and. (itail .lt. 127)) then
             itail = itail+1
             compact(itail:itail) = tail(i:i)
           end if
         end do

c        join tail to head within the allowable space
         itail = min(itail,headlen-ihead)
         if (itail .gt. 0) then
           head(ihead:ihead) = '.'
           head(ihead+1:ihead+itail) = compact(1:itail)
         endif

         return
         end

c The following utility explicitly sets all the characters in a string
c to blanks

         subroutine blankout(name, namelen)

         character*(*) name
         integer namelen, i

         do  i = 1, namelen
           name(i:i) = ' '
         end do

         return
         end
