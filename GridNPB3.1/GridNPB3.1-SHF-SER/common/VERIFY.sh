TURNAROUND_TIME=$SECONDS

echo Total checksum is $TOTAL_CHECKSUM, verification checksum is $TOTAL_CHECKSUM_VERIFY
RELERR=`echo "x=( $TOTAL_CHECKSUM - $TOTAL_CHECKSUM_VERIFY ) / $TOTAL_CHECKSUM_VERIFY ; \
              if (x<0) x=(-1)*x; x"   | bc -l`
# We don't want to print a gazillion zeroes behind the decimal point of 
# the relative error, so we scale it up by 10^8 and only print nine
# characters of the result. 

RELERR8=`echo "scale=10; $RELERR * 100000000"   | bc -l`
RELERR8=`echo $RELERR8 | sed 's/^\(.........\).*$/\1/'`
echo Relative error is ${RELERR8}d-08

epsilon=0.00000001
VERIFIED=`echo "x=0; if ($RELERR < $epsilon) x=1; x"   | bc -l`

if [ $VERIFIED -eq 1 ]; then
  echo Benchmark $FULLNAME.$NGBCLASS completed successfully
else
  echo Benchmark $FULLNAME.$NGBCLASS completed unsuccessfully
fi

echo Turnaround time: $TURNAROUND_TIME seconds
