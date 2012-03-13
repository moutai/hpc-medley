c NPROCS = 1 CLASS = C
c  
c  
c  This file is generated automatically by the setparams utility.
c  It sets the number of processors and the class of the NPB
c  in this directory. Do not modify it by hand.
c  
        character class
        parameter (class='C')
        integer num_procs
        parameter (num_procs=1)
        integer x_zones, y_zones
        parameter (x_zones=4, y_zones=4)
        integer gx_size, gy_size, gz_size
        parameter (gx_size=480, gy_size=320, gz_size=28)
        integer problem_size
        parameter (problem_size = 120)
        integer max_xysize, max_xybcsize
        parameter (max_xysize=154880, max_xybcsize=31520)
        integer max_numzones
        parameter (max_numzones=16)

c number of iterations and how often to print the norm
        integer itmax_default, inorm_default
        parameter (itmax_default=250, inorm_default=250)
        double precision dt_default, ratio
        parameter (dt_default = 2.0d0, ratio = 1.d0)
        logical  convertdouble
        parameter (convertdouble = .false.)
        character compiletime*11
        parameter (compiletime='12 Mar 2012')
        character npbversion*3
        parameter (npbversion='3.1')
        character cs1*6
        parameter (cs1='(none)')
        character cs2*9
        parameter (cs2='$(MPIF77)')
        character cs3*6
        parameter (cs3='(none)')
        character cs4*6
        parameter (cs4='(none)')
        character cs5*19
        parameter (cs5='-O3  -mcmodel=large')
        character cs6*3
        parameter (cs6='-O3')
        character cs7*6
        parameter (cs7='randi8')
