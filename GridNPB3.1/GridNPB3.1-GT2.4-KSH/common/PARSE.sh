if [ $# -eq 0 ]; then
  echo "Usage: \"$0 CLASS [options]\""
  echo "   CLASS:                     S, W, A, or B"
  echo "   options: -u                unformatted data files"
  echo "            -v                verbose mode"
  echo "            -RF               Rapid Fire"
  echo "            -ftp=VALUE        file transfer method:            GSISCP (default) or GRIDFTP"
  echo "            -jmgr=VALUE       job manager:                     FORK (default) or QUEUE or DEFAULT"
  echo "            -path=VALUE       search path on execution hosts:  colon-separated path"
  echo "            -deploy=VALUE     copy scripts and executables:    AUTOMATIC (default) or MANUAL"
  echo "            -timeout=VALUE    time before any task times out:  seconds"
  exit
fi

FTP_TYPE=default
JOBMANAGER=default
ADDPATH=default
NGBCLASS=default
TIMEOUT=default
DEPLOY=default
#The default script behavior is nonverbose
VERBOSE=0
# the default data file format is ASCII
ASCII=1
#The default execution mode is ALU intensive (not Rapid Fire)
RAPIDFIRE=0

NUMPARS=$#
PAR=1
while [ $PAR -le $NUMPARS ]; do
  eval OPT=\$$PAR
  OPTNAME=`echo $OPT |  awk 'BEGIN{ FS = "=" }{ print $1 }'`
  OPTVAL=`echo $OPT  |  awk 'BEGIN{ FS = "=" }{ print $2 }'`
  case $OPTNAME in
    -u        ) ASCII=0                                                    ;;
    -v        ) VERBOSE=1                                                  ;;
    -RF       ) RAPIDFIRE=1                                                ;;
    -ftp      ) if [ $FTP_TYPE != default ]; then
                  echo Error, may only select ftp once; exit
                fi
                case $OPTVAL in
                  GSISCP  ) FTP_TYPE=$OPTVAL                               ;;
                  GRIDFTP ) FTP_TYPE=$OPTVAL                               ;;
                  ""      ) FTP_TYPE=GSISCP                                ;;
                  *       ) echo Error, wrong ftp selection $OPTVAL; exit  ;;
                esac                                                       ;;
    -jmgr     ) if [ $JOBMANAGER != default ]; then
                  echo Error, may only select jmgr once; exit
                fi
                case $OPTVAL in
                  FORK    ) JOBMANAGER=/jobmanager-fork                    ;;
                  QUEUE   ) JOBMANAGER=/jobmanager-PBS                     ;;
                  DEFAULT ) JOBMANAGER=                                    ;;
                  ""      ) JOBMANAGER=/jobmanager-fork                    ;;
                  *       ) echo Error, wrong jmgr selection $OPTVAL; exit ;;
                esac                                                       ;;
    -path     ) if [ $ADDPATH != default ]; then
                  echo Error, may only select path once; exit
                fi
                ADDPATH=$OPTVAL                                            ;;
    -deploy   ) if [ $DEPLOY != default ]; then
                  echo Error, may only select deployment type once; exit
                fi
                case $OPTVAL in
                  MANUAL | AUTOMATIC ) DEPLOY=$OPTVAL                      ;;
                  * ) echo Error, wrong deployment selection $OPTVAL; exit ;;
                esac                                                       ;;
    -timeout  ) if [ $TIMEOUT != default ]; then
                  echo Error, may only select timeout once; exit
                else
                  if [ $OPTVAL -le 0 ]; then
                    echo Error, must select positive timeout; exit
                  else
                    TIMEOUT=$OPTVAL
                  fi
                fi                                                         ;;
    S | W | A | B ) if [ $NGBCLASS != default ]; then
                  echo Error, may only select class once; exit
                fi
                NGBCLASS=$OPTNAME                                             ;;
    *         ) echo Error, wrong option $OPTNAME; exit                    ;;
  esac
  PAR=`expr $PAR + 1`
done

if [ $VERBOSE -eq 0 ]; then
  OUT="> /dev/null 2>&1"
fi

if [ "$FTP_TYPE"   = default ]; then FTP_TYPE=GSISCP;             fi
if [ "$JOBMANAGER" = default ]; then JOBMANAGER=/jobmanager-fork; fi
if [ "$ADDPATH"    = default ]; then 
  eval echo "WARNING, no remote search path specified. You may experience" $OUT
  eval echo "problems. Using default path in config/path.def.template:"    $OUT
  eval echo `cat config/path.def.template`                                 $OUT
  ADDPATH=`cat config/path.def.template`
fi
if [ "$DEPLOY"     = default ]; then DEPLOY=AUTOMATIC;            fi

if [ "$NGBCLASS"      = default ]; then
  echo Error, problem class not specified; exit
fi

if [ RAPIDFIRE -eq 0 ]; then
  FULLNAME=$NAME
  NPBCLASS=$NGBCLASS
else
  FULLNAME=${NAME}-RF
  NPBCLASS=S
fi

if [ "$TIMEOUT"    = default ]; then
  #set some reasonable values for the timeout
  case $NGBCLASS in
    S) TIMEOUT=100    ;;
    W) TIMEOUT=800   ;;
    A) TIMEOUT=2000  ;;
    B) TIMEOUT=8000  ;;
    *) TIMEOUT=0     ;;
  esac
fi

if [ ! -f config/ngbhosts ]; then
  eval echo "WARNING, no NGB hosts specified in config/ngbhosts."          $OUT
  eval echo "Using local host "                                            $OUT
  eval echo `hostname`                                                     $OUT
  hostname > config/ngbhosts
fi

PID=$$

. ./common/CHECKSUMS.sh
