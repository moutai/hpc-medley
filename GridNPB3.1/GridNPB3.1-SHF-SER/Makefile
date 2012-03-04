SHELL=/bin/sh
CLASS=U

default: header
	@ sys/print_instructions

ED: ed
ed: sp

HC: hc
hc: lu bt sp mf

VP: vp
vp: bt mg ft mf

#MB uses all NPB's, plus the mesh filter
ALL: mb
all: mb
MB: mb
mb: sp bt lu mg ft mf

BT: bt
bt: header
	cd BT; $(MAKE) CLASS=$(CLASS)
		       
SP: sp		       
sp: header	       
	cd SP; $(MAKE) CLASS=$(CLASS)
		       
LU: lu		       
lu: header	       
	cd LU; $(MAKE) CLASS=$(CLASS)
		       
MG: mg		       
mg: header	       
	cd MG; $(MAKE) CLASS=$(CLASS)
		       
FT: ft		       
ft: header	       
	cd FT; $(MAKE) CLASS=$(CLASS)
		       
MF: mf
mf: header
	cd MF; $(MAKE) CLASS=$(CLASS)


# It would be nice to make clean in each subdirectory (the targets
# are defined) but on a really clean system this will won't work
# because those makefiles need config/make.def
clean:
	- rm -f core 
	- rm -f *~ */core */*~ */*.o */npbparams.h */*.obj */*.exe 
	- rm -f bin/sp.* bin/lu.* bin/mg.* bin/ft.* bin/bt.* bin/mf.*
	- rm -f sys/setparams  sys/setparams.h

veryclean: clean
	- rm -f config/make.def 


header:
	@ sys/print_header
