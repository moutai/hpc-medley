    LOG_FILE=____LOG_$NAME.$TASK.$PID
    if [ $VERBOSE -eq 1 ] || [ $VERIFY -eq 1 ]; then
      ERR=____ERR.$TASK.$PID
    else
      ERR=/dev/null
    fi

    echo Task $TASK, code $CODE.$NPBCLASS, host $HOST -- ${VERIFY_STRING[$VERIFY]}

    echo "&(executable=NODE.sh.$EXT)\
    (directory=$DIR)\
    (stdout=$NGBHOME/$LOG_FILE)\
    (arguments=NODE)\
    (environment=(CODE          '$CODE')\
                 (NPBCLASS      '$NPBCLASS')\
                 (NGBCLASS      '$NGBCLASS')\
                 (ASCII         '$ASCII')\
                 (NAME          '$NAME')\
                 (FULLNAME      '$FULLNAME')\
                 (TASK          '$TASK')\
                 (WIDTH         '$WIDTH')\
                 (DEPTH         '$DEPTH')\
                 (PID           '$PID')\
                 (VERBOSE       '$VERBOSE')\
                 (FILTER        '$FILTER')\
                 (MODE          '$MODE')\
                 (TIMEOUT       '$TIMEOUT')\
                 (OUTNAME_MF    '$OUTNAME_MF')\
                 (OUTNAME_NPB1  '$OUTNAME_NPB1')\
                 (OUTNAME_NPB2  '$OUTNAME_NPB2')\
                 (OUTXSIZE      '$OUTXSIZE')\
                 (OUTYSIZE      '$OUTYSIZE')\
                 (OUTZSIZE      '$OUTZSIZE ')\
                 (NUM_INPUTS    '$NUM_INPUTS')\
                 (NUM_OUTPUTS   '$NUM_OUTPUTS')\
                 (HOST          '$HOST')\
                 (FS            '$FS')\
                 (OUTHOST1      '$OUTHOST1')\
                 (OUTHOST2      '$OUTHOST2')\
                 (OUTFS1        '$OUTFS1')\
                 (OUTFS2        '$OUTFS2')\
                 (INNAME_MF1    '$INNAME_MF1')\
                 (INNAME_MF2    '$INNAME_MF2')\
                 (INNAME_MF3    '$INNAME_MF3')\
                 (INXSIZE1      '$INXSIZE1')\
                 (INYSIZE1      '$INYSIZE1')\
                 (INZSIZE1      '$INZSIZE1')\
                 (INXSIZE2      '$INXSIZE2')\
                 (INYSIZE2      '$INYSIZE2')\
                 (INZSIZE2      '$INZSIZE2')\
                 (INXSIZE3      '$INXSIZE3')\
                 (INYSIZE3      '$INYSIZE3')\
                 (INZSIZE3      '$INZSIZE3')\
                 (NGBHOME       '$NGBHOME')\
                 (EXT           '$EXT')\
                 (FTP_TYPE      '$FTP_TYPE')\
                 (ADDPATH       '$ADDPATH')\
                 (ERR           '$ERR'))" > RSL_NODE.$TASK.$PID
    eval 'JOBID[$TASK]=`globusrun -b -s -r $HOST$JOBMANAGER \
                                        -f RSL_NODE.$TASK.$PID`' $OUT
    JOBSTATUS[$TASK]=SUBMITTED
    rm -f RSL_NODE.$TASK.$PID                                    $OUT
  
