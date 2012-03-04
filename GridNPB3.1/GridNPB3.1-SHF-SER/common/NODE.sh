echo Task $TASK, code $CODE.$NPBCLASS -- ${VERIFY_STRING[$VERIFY]}

LOG_FILE=____LOG_$NAME.$TASK.$PID
if [ $VERBOSE -eq 1 ] || [ $VERIFY -eq 1 ]; then
  ERR=____ERR.$TASK.$PID
else
  ERR=/dev/null
fi

# we need $NUM_INPUTS input files for the mesh filter. If $NUM_INPUTS 
# is smaller than three, the remaining arguments to mf.$NPBCLASS are
# ignored.
if [ $FILTER -ne 0 ]; then
  # interpolate  solutions between meshes
  eval "(./bin/mf.$NPBCLASS <<-EOF; )                 | $THROWIT $LOG_FILE
	$ASCII
	$MODE
	$OUTNAME_MF
	$OUTXSIZE $OUTYSIZE $OUTZSIZE
	$NUM_INPUTS
	$INNAME_MF1
	$INXSIZE1  $INYSIZE1  $INZSIZE1
	$INNAME_MF2
	$INXSIZE2  $INYSIZE2  $INZSIZE2
	$INNAME_MF3
	$INXSIZE3  $INYSIZE3  $INZSIZE3
	EOF"

  # remove filter input files

  if  [ $NAME != "MB" ]; then
    NUM=1
    while [ $NUM -le $NUM_INPUTS ]; do
      eval FNAME=\$INNAME_MF$NUM
      rm -f $FNAME
      eval "echo Removed filter input file $FNAME    | $THROWIT $LOG_FILE"
      NUM=`expr $NUM + 1`
    done
  elif [ $NUM_INPUTS -ne 0 ]; then
    case $SUB_TASK in
    0 ) ;;
    1 ) rm -f $INNAME_MF1 $INNAME_MF2
        ;;
    * ) rm -f $INNAME_MF1
        ;;
    esac
  fi
else
  if [ $NUM_INPUTS -eq 1 ]; then
    mv $INNAME_MF1 $OUTNAME_MF
  fi
fi  

# execute the actual NPB
  eval "(./bin/$CODE.$NPBCLASS <<-EOF; echo \$? > $ERR;) | $THROWIT $LOG_FILE
	$ASCII
	$FULLNAME 
	$NPBCLASS
	$NGBCLASS
	$TASK 
	$WIDTH
	$DEPTH 
	$PID
	$VERBOSE
	EOF"

if [ $VERIFY -eq 1 ]; then
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
  
rm -f $LOG_FILE
if [ "$ERR" != "/dev/null" ]; then rm -f $ERR; fi

# remove the NPB input file
 rm -f $OUTNAME_MF

