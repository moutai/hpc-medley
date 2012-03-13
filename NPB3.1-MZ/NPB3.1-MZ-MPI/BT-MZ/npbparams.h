c NPROCS = 25 CLASS = D
c  
c  
c  This file is generated automatically by the setparams utility.
c  It sets the number of processors and the class of the NPB
c  in this directory. Do not modify it by hand.
c  
        character class
        parameter (class='D')
        integer num_procs
        parameter (num_procs=25)
        integer x_zones, y_zones
        parameter (x_zones=32, y_zones=32)
        integer gx_size, gy_size, gz_size, niter_default
        parameter (gx_size=1632, gy_size=1216, gz_size=34)
        parameter (niter_default=250)
        integer problem_size
        parameter (problem_size = 98)
        integer max_xysize, max_xybcsize
        parameter (max_xysize=80656, max_xybcsize=37750)
        integer max_numzones
        parameter (max_numzones=41)
        double precision dt_default, ratio
        parameter (dt_default = 0.00002d0, ratio = 4.5d0)
        logical  convertdouble
        parameter (convertdouble = .false.)
        character compiletime*11
        parameter (compiletime='13 Mar 2012')
        character npbversion*3
        parameter (npbversion='3.1')
        character cs1*7
        parameter (cs1='mpif77 ')
        character cs2*6
        parameter (cs2='$(F77)')
        character cs3*5
        parameter (cs3='-lmpi')
        character cs4*6
        parameter (cs4='(none)')
        character cs5*27
        parameter (cs5='-O3 --openmp -mcmodel=large')
        character cs6*27
        parameter (cs6='-O3 --openmp -mcmodel=large')
        character cs7*6
        parameter (cs7='randi8')
