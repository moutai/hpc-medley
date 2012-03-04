#start a timer to see if a timeout has been reached
SECONDS2=$SECONDS

VERIFIED=1
NUMCOMPLETED=0
case $NAME in
  ED) FIRST_VERIFY_TASK=0 ;;
  HC) FIRST_VERIFY_TASK=`expr $MAX_TASK - 1` ;;
  VP) FIRST_VERIFY_TASK=`expr $MAX_TASK - 1` ;;
  MB) FIRST_VERIFY_TASK=`expr $MAX_TASK - $WIDTH` ;;
   *) FIRST_VERIFY_TASK=0 ;;
esac
if [ $VERBOSE -eq 0 ]; then
  START_MONITOR=$FIRST_VERIFY_TASK 
else
  START_MONITOR=0
fi

TOTAL_CHECKSUM=0
NUMCOMPLETED=$START_MONITOR

while [ $NUMCOMPLETED -lt $MAX_TASK ]; do
  TASK=$START_MONITOR
  # do not check too often
  sleep 1
  if [ `expr $SECONDS - $SECONDS2` -ge $TIMEOUT ]; then
    echo Exceeded timeout of $TIMEOUT seconds while waiting for input 
    VERIFIED=0
    break
  fi
  while [ $TASK -lt $MAX_TASK ]; do
    if [ "${JOBSTATUS[$TASK]}" = "SUBMITTED" ] && \
       [ "`globus-job-status ${JOBID[$TASK]}`" = "DONE" ]; then
      JOBSTATUS[$TASK]=DONE
      NUMMOD=`expr $TASK % $NUMHOSTS`
      HOST=`echo ${GRIDPOINT[$NUMMOD]} | awk 'BEGIN{ FS = ":" }{ print $1 }'`
      DIR=`echo ${GRIDPOINT[$NUMMOD]}  | awk 'BEGIN{ FS = ":" }{ print $2 }'`
      if [ "$DIR" = "" ]; then DIR="." ; fi
      LOG_FILE=____LOG_$NAME.$TASK.$PID
      ERR=____ERR.$TASK.$PID
      if  [ "$FTP_TYPE" = GSISCP ]; then
        eval gsiscp $HOST:$DIR/$NGBHOME/{$LOG_FILE,$ERR} .              $OUT
      else
        eval gsincftpget $HOST . $NGBHOME/$LOG_FILE $DIR/$NGBHOME/$ERR  $OUT
      fi
      eval cat $LOG_FILE                                                $OUT
      if [ $TASK -ge $FIRST_VERIFY_TASK ]; then
        ERROR_STATUS=`cat $ERR`
        if [ $ERROR_STATUS -ne 0 ]; then
          if [ $VERBOSE -eq 1 ]; then echo Task $TASK failed; fi
          VERIFIED=0
        else
          CHECKLINE=`cat $LOG_FILE | grep "Normalized checksum" `
          LINE_COUNT=`echo $CHECKLINE | wc -l`
          if [ $LINE_COUNT -eq 0 ]; then
            if [ $VERBOSE -eq 1 ]; then echo Task $TASK failed; fi
            VERIFIED=0
          else
            if [ $VERBOSE -eq 1 ]; then echo Task $TASK completed successfully; fi
            CHECKSUM=`echo $CHECKLINE | awk '{ print $3 }'`
            TOTAL_CHECKSUM=`echo "scale=15; $TOTAL_CHECKSUM + $CHECKSUM"  | bc`
          fi
        fi
      fi
      NUMCOMPLETED=`expr $NUMCOMPLETED + 1`
      rm -f $LOG_FILE
      if [ "$ERR" != "/dev/null" ]; then rm -f $ERR; fi
    fi
    TASK=`expr $TASK + 1`
  done
done

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
  echo Benchmark FULL$NAME.$NGBCLASS completed unsuccessfully
fi

TURNAROUND_TIME=$SECONDS
SECONDS=0

#Now do the cleanup
NUM=0
while [ $NUM -lt $NUMUNIQUEFSS ]; do
  HOST=`echo ${TOTUNIQUEFS[$NUM]} | awk 'BEGIN{ FS = ":" }{ print $1 }'`
  DIR=`echo ${TOTUNIQUEFS[$NUM]}  | awk 'BEGIN{ FS = ":" }{ print $2 }'`
  if [ "$DIR" = "" ]; then DIR="." ; fi
  echo "&(executable=NODE.sh.$EXT)\
  (directory=$DIR)\
  (arguments=RM-R $PID)\
  (environment=(ADDPATH     '$ADDPATH'))" > RSL_RM-R.$NUM.$PID
  eval "globusrun -s -r $HOST$JOBMANAGER -f RSL_RM-R.$NUM.$PID       $OUT"
  rm -f RSL_RM-R.$NUM.$PID            
  eval echo Removed temporary files from ${TOTUNIQUEFS[$NUM]}        $OUT
  NUM=`expr $NUM + 1`
done

echo Turnaround time: $TURNAROUND_TIME seconds, \
deployment time: $DEPLOYMENT_TIME seconds, \
cleanup time: $SECONDS seconds 
