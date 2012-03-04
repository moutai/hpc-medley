echo Running GridNPB3.1-GT2.4-KSH code $FULLNAME                     
echo Class is $NGBCLASS
if [ NAME != ED ]; then
  if [ ASCII -eq 1 ]; then
    echo Data files are in ASCII
  else
    echo Data files are unformatted
  fi
fi
echo Number of tasks is $MAX_TASK     
echo Names of executables are $EXES.$NPBCLASS     
echo Using $FTP_TYPE and jobmanager $JOBMANAGER

if [ $DEPLOY = MANUAL ]; then
  EXT=`hostname -s`.scratch
else    
  EXT=`hostname -s`.$PID
fi
SECONDS=0
NGBHOME=NGB.$EXT

#read the hosts
NUMHOSTS=0
HETEROGENEOUS=0
cat config/ngbhosts | while read LINE && [ $NUMHOSTS -lt $MAX_TASK ]; do
  if [ "$LINE" != "" ]; then
    set -A PAIR $LINE
    GRIDPOINT[$NUMHOSTS]=${PAIR[0]}
    ARCH[$NUMHOSTS]=${PAIR[1]}
    if [ $NUMHOSTS -gt 0 ] &&
       [ "${ARCH[$NUMHOSTS]}" != "${ARCH[`expr $NUMHOSTS - 1`]}" ]; then
      HETEROGENEOUS=1
    fi
    NUMHOSTS=`expr $NUMHOSTS + 1`
  fi
done

if [ $HETEROGENEOUS -ne 0 ] && [ $ASCII -ne 1 ]; then
  echo \*\*\* Warning, different architectures and unformatted data files \*\*\*
fi

NUMUNIQUEGRIDPOINTS=0
head -n $NUMHOSTS config/ngbhosts | awk '{ print $1 }' | sort -u | while read LINE; do
  UNIQUEGRIDPOINT[$NUMUNIQUEGRIDPOINTS]=$LINE
  NUMUNIQUEGRIDPOINTS=`expr $NUMUNIQUEGRIDPOINTS + 1`
done

#create scratch home directories on all uniquely named hosts 
if [ $DEPLOY = AUTOMATIC ]; then
  NUM=0
  while [ $NUM -lt $NUMUNIQUEGRIDPOINTS ]; do
    HOST=`echo ${UNIQUEGRIDPOINT[$NUM]} | awk 'BEGIN{ FS = ":" }{ print $1 }'`
    DIR=`echo ${UNIQUEGRIDPOINT[$NUM]}  | awk 'BEGIN{ FS = ":" }{ print $2 }'`
    if [ "$DIR" = "" ]; then DIR="."; fi
    eval "gsiscp -p common/NODE.sh $HOST:$DIR/NODE.sh.$EXT        $OUT"
    echo "&(executable=NODE.sh.$EXT)\
    (directory=$DIR)\
    (arguments=MKDIR $NGBHOME)\
    (environment=(ADDPATH     '$ADDPATH'))" > RSL_MKDIR.$NUM.$PID
    eval "globusrun -s -r $HOST$JOBMANAGER -f RSL_MKDIR.$NUM.$PID $OUT"
    rm -f RSL_MKDIR.$NUM.$PID
    NUM=`expr $NUM + 1`
  done
fi
  
#determine which unique grid points share file systems

#step one: create list of host names on each host (will append in case of sharing).
#          We add some funny characters to the host name so that we can search for
#          lines that include them (important if the batch system adds junk to stdout)
NUM=0
while [ $NUM -lt $NUMUNIQUEGRIDPOINTS ]; do
  HOST=`echo ${UNIQUEGRIDPOINT[$NUM]} | awk 'BEGIN{ FS = ":" }{ print $1 }'`
  POINT=${UNIQUEGRIDPOINT[$NUM]}
  DIR=`echo ${UNIQUEGRIDPOINT[$NUM]}  | awk 'BEGIN{ FS = ":" }{ print $2 }'`
  if [ "$DIR" = "" ]; then DIR="." ; fi
  echo "&(executable=NODE.sh.$EXT)\
  (directory=$DIR)\
  (stdout=$NGBHOME/FSLIST.$PID)\
  (arguments=ECHO %H%O%S%T%N%A%M%E$POINT)\
  (environment=(ADDPATH     '$ADDPATH'))" > RSL_ECHO.$NUM.$PID
  eval "globusrun -s -r $HOST$JOBMANAGER -f RSL_ECHO.$NUM.$PID    $OUT"
  rm -f RSL_ECHO.$NUM.$PID            
  NUM=`expr $NUM + 1`
done

#step two: fetch the list of host names, sort, and select the "smallest"
NUM=0
while [ $NUM -lt $NUMUNIQUEGRIDPOINTS ]; do
  HOST=`echo ${UNIQUEGRIDPOINT[$NUM]} | awk 'BEGIN{ FS = ":" }{ print $1 }'`
  POINT=${UNIQUEGRIDPOINT[$NUM]}
  DIR=`echo ${UNIQUEGRIDPOINT[$NUM]}  | awk 'BEGIN{ FS = ":" }{ print $2 }'`
  if [ "$DIR" = "" ]; then DIR="." ; fi
  if [ "$FTP_TYPE" = GSISCP ]; then 
    eval gsiscp $HOST:$DIR/$NGBHOME/FSLIST.$PID  .                $OUT 
  else
    eval gsincftpget $HOST . $DIR/$NGBHOME/FSLIST.$PID            $OUT
  fi
  FS=`grep %H%O%S%T%N%A%M%E FSLIST.$PID | sed 's/%H%O%S%T%N%A%M%E//' \
                                        | sort -u | head -n 1`
  FS2=`echo $FS | awk 'BEGIN{ FS = ":" }{ print $2 }'`
  if [ "$FS2" = "" ]; then FS=`echo $FS | awk 'BEGIN{ FS = ":" }{ print $1 }'`; fi
  # find out which nodes in the graph use this file system
  NUMH=0
  while [ $NUMH -lt $NUMHOSTS ]; do
    if [ "$POINT" = "${GRIDPOINT[$NUMH]}" ]; then
      UNIQUEFS[$NUMH]="$FS"
      UNIQUEARCH="${ARCH[$NUMH]}"
    fi
    NUMH=`expr $NUMH + 1`
  done
  # we keep a list of all unique File Systems
  # add the name of the architecture to the File System
  echo "$FS"%A%R%C%H%$UNIQUEARCH >> TOTFSLIST.$PID
  rm -f FSLIST.$PID
  NUM=`expr $NUM + 1`
done

#step three: determine the number of unique hosts that do not share file systems
sort TOTFSLIST.$PID -u > UNIQUEFSLIST.$PID
rm -f TOTFSLIST.$PID
NUMUNIQUEFSS=0
cat UNIQUEFSLIST.$PID | while read LINE; do
  TOTUNIQUEFS[$NUMUNIQUEFSS]=`echo $LINE | awk 'BEGIN{ FS = "%A%R%C%H%" }{ print $1 }'`
  ARCH[$NUMUNIQUEFSS]=`echo $LINE        | awk 'BEGIN{ FS = "%A%R%C%H%" }{ print $2 }'`
  NUMUNIQUEFSS=`expr $NUMUNIQUEFSS + 1`
done
rm -f UNIQUEFSLIST.$PID

#copy scripts and executables to all unique hosts that don't share file systems
if [ $DEPLOY = AUTOMATIC ]; then
  NUM=0
  while [ $NUM -lt $NUMUNIQUEFSS ]; do
    HOST=`echo ${TOTUNIQUEFS[$NUM]} | awk 'BEGIN{ FS = ":" }{ print $1 }'`
    DIR=`echo ${TOTUNIQUEFS[$NUM]}  | awk 'BEGIN{ FS = ":" }{ print $2 }'`  
    if [ "$DIR" = "" ]; then DIR="." ; fi
    if [ "${ARCH[$NUM]}" != "" ]; then ARCH[$NUM]=."${ARCH[$NUM]}" ; fi
    SOURCE_LIST="bin${ARCH[$NUM]}/$EXES.$NPBCLASS"
    # Note: there is no portable way of putting executables on the remote host using
    #       GRIDftp, so we always use gsiscp.
    eval gsiscp -p $SOURCE_LIST      $HOST:$DIR/$NGBHOME          $OUT 
    eval echo Copied $SOURCE_LIST to $HOST:$DIR/$NGBHOME          $OUT
    NUM=`expr $NUM + 1`
  done
fi

DEPLOYMENT_TIME=$SECONDS
SECONDS=0

set -A VERIFY_STRING " no verification being performed" " being verified"
