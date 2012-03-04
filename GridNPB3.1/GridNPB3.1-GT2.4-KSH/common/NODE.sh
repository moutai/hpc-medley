#! /bin/ksh

if [ ! "$PATH" ]; then
  PATH=$ADDPATH
else
  PATH=$PATH:$ADDPATH
fi

case $1 in
MKDIR ) mkdir $2;                       exit;;
ECHO  ) echo  $2;                       exit;;
RM-R  ) rm -f -r *.$2 NGB.scratch/*.$2; exit;;
TOUCH ) touch $2;                       exit;;
esac

TWO=".2"

cd $NGBHOME

# Block until all inputs from the previous node in the data flow graph are 
# available. We do that by checking existence of a semaphore file once a
# second.
NUM=1
while [ $NUM -le $NUM_INPUTS ]; do 
  RECEIVED[$NUM]=0
  NUM=`expr $NUM + 1`
done

#start a timer to see if a timeout has been reached
SECONDS=0

NUM_INPUTS_RECEIVED=0
while [ $NUM_INPUTS_RECEIVED -lt $NUM_INPUTS ]; do
  # Do not poll too frequently
  sleep 1
  if [ $SECONDS -ge $TIMEOUT ]; then
    echo Exceeded timeout of $TIMEOUT seconds while waiting for input 
    exit
  fi
  NUM=1
  while [ $NUM -le $NUM_INPUTS ]; do
    eval SEMAPHORE=\$INNAME_MF$NUM.SEM

    if  [ ${RECEIVED[$NUM]} -eq 0 ] && ( [ -f $SEMAPHORE ] || [ -f $SEMAPHORE$TWO ] ); then
      # cannot yet remove the semaphore file because the delivering host may then 
      # think the input data can be removed if it uses the same file system
      RECEIVED[$NUM]=1
      NUM_INPUTS_RECEIVED=`expr $NUM_INPUTS_RECEIVED + 1`
      if [ -f $SEMAPHORE$TWO ]; then
        echo Found semaphore file $SEMAPHORE$TWO
      else
        echo Found semaphore file $SEMAPHORE              
      fi
    fi
    NUM=`expr $NUM + 1`
  done
done

# we need $NUM_INPUTS input files for the mesh filter. If $NUM_INPUTS 
# is smaller than three, the remaining arguments to mf.$NPBCLASS are
# ignored.
if [ $FILTER -ne 0 ]; then
  # interpolate  solutions between meshes
  ./mf.$NPBCLASS <<-EOF 
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

	EOF

  # remove filter input files
  NUM=1
  while [ $NUM -le $NUM_INPUTS ]; do
    eval FNAME=\$INNAME_MF$NUM
    # make exception for MB; if the semaphore file exists that says two graph nodes
    # on the _same_ file system use the filter input file, merely rename the semaphore
    if [ $NAME = "MB" ] && [ -f $FNAME.SEM$TWO ]; then
      mv $FNAME.SEM$TWO $FNAME.SEM
      echo Moved semaphore file $FNAME.SEM$TWO to $FNAME.SEM 
    else  
      rm -f $FNAME $FNAME.SEM
      echo Removed filter input file $FNAME and its semaphore file
    fi
    NUM=`expr $NUM + 1`
  done
else
  if [ $NUM_INPUTS -eq 1 ]; then
    mv $INNAME_MF1 $OUTNAME_MF
    rm -f $INNAME_MF1.SEM
  fi
fi  

FSROOT=`echo $FS  |  awk 'BEGIN{ FS = ":" }{ print $1 }'`

# execute the actual NPB
./$CODE.$NPBCLASS <<-EOF ; echo $? > $ERR; 
	$ASCII
	$FULLNAME
	$NPBCLASS
	$NGBCLASS
	$TASK
	$WIDTH
	$DEPTH
	$PID
	$VERBOSE
	EOF

# remove the NPB input file
 rm -f $OUTNAME_MF

# send the output(s) to the respective receiving hosts; must make an exception
# for MB in case both output file systems are the same, because we don't want
# to copy the same file twice to the same file system
if [ $NAME = "MB" ] && [ $NUM_OUTPUTS -ne 0 ] && [ "$OUTFS1" = "$OUTFS2" ]; then 
  NUM_OUTPUTS=1
  SUFFIX=$TWO
fi

NUM=1
while [ $NUM -le $NUM_OUTPUTS ]; do
  eval OUTHOST=\$OUTHOST$NUM
  eval OUTFS=\$OUTFS$NUM
  OUTFSROOT=`echo $OUTFS | awk 'BEGIN{ FS = ":" }{ print $1 }'`
  DIR=`echo $OUTFS       | awk 'BEGIN{ FS = ":" }{ print $2 }'`
  if [ "$DIR" = "" ]; then DIR="." ; fi
  eval OUTNAME=\$OUTNAME_NPB$NUM
  SEMAPHORE=$OUTNAME.SEM$SUFFIX
  if [ "$FS" != "$OUTFS" ]; then
     if  [ "$FTP_TYPE" = GSISCP ]; then 
        eval gsiscp -p $OUTNAME $OUTFSROOT:$DIR/$NGBHOME 
     else
        eval gsincftpput $OUTFSROOT $DIR/$NGBHOME $OUTNAME
     fi
#    comment out the following line when the touch strategy is used. We use an
#    empty file as the semaphore; renaming at the receiving side requires gsiscp
     touch EMPTY.$PID
     eval gsiscp -p EMPTY.$PID $OUTFSROOT:$DIR/$NGBHOME/$SEMAPHORE
     echo Sent $OUTNAME and its semaphore from $FS to $OUTFS            
#    echo "&(executable=NODE.sh.$EXT)\
#    (directory=$DIR)\
#    (arguments=TOUCH $NGBHOME/$SEMAPHORE)\
#    (environment=(ADDPATH     '$ADDPATH'))" > RSL_TOUCH.$NUM.$EXT
#    eval "globusrun -s -r $HOST$JOBMANAGER -f RSL_TOUCH.$NUM.$EXT $OUT"
#    rm -f RSL_TOUCH.$NUM.$EXT            
  else
     touch $SEMAPHORE
     echo Touched semaphore $SEMAPHORE on local system $FS
  fi
  NUM=`expr $NUM + 1`
done

# ... and clean up; must make an exception again for MB
if [ $NAME = "MB" ] && [ $NUM_OUTPUTS -eq 2 ]; then
  if [ "$FS" != "$OUTFS1" ] && [ "$FS" != "$OUTFS2" ]; then
    rm -f $OUTNAME_NPB1
    echo Removed $OUTNAME_NPB1 from $FS                 
  fi
else
  NUM=1
  while [ $NUM -le $NUM_OUTPUTS ]; do
    eval OUTFS=\$OUTFS$NUM
    eval OUTNAME=\$OUTNAME_NPB$NUM
    if [ "$FS" != "$OUTFS" ]; then
      rm -f $OUTNAME
      echo Removed $OUTNAME from $FS                   
    fi
    NUM=`expr $NUM + 1`
  done
fi
