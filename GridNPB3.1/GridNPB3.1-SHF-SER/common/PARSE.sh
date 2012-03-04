if [ $# -eq 0 ]; then
  echo "Usage: \"$0 CLASS [options]\""
  echo "   CLASS:                     S, W, A, or B"
  echo "   options: -u                unformatted data files"
  echo "            -v                verbose mode"
  echo "            -RF               Rapid Fire"
  exit
fi

NGBCLASS=default
#The default script behavior is nonverbose
VERBOSE=0
#The default data file format is ASCII
ASCII=1
#The default execution mode is ALU intensive (not Rapid Fire)
RAPIDFIRE=0

NUMPARS=$#
PAR=1
while [ $PAR -le $NUMPARS ]; do
  eval OPT=\$$PAR
  OPTNAME=`echo $OPT |  awk '{ FS = "="; print $1 }'`
  OPTVAL=`echo $OPT |  awk '{ FS = "="; print $2 }'`
  case $OPTNAME in
    -u        ) ASCII=0                                                    ;;
    -v        ) VERBOSE=1                                                  ;;
    -RF       ) RAPIDFIRE=1                                                ;;
    S | W | A | B ) if [ $NGBCLASS != default ]; then
                      echo Error, may only select class once; exit
                    fi
                NGBCLASS=$OPTNAME                                          ;;
    *         ) echo Error, wrong option $OPTNAME; exit                    ;;
  esac
  PAR=`expr $PAR + 1`
done

if [ $VERBOSE -eq 1 ]; then
  THROWIT="tee"
else
  THROWIT="cat >"
fi

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

PID=$$

. ./common/CHECKSUMS.sh
