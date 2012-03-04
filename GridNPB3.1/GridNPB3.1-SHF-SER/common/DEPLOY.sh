echo Running GridNPB3.1-SHF-SER code $FULLNAME
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
SECONDS=0
TOTAL_CHECKSUM=0
VERIFIED=1

set -A VERIFY_STRING " no verification being performed" " being verified"
