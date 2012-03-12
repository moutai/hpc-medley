c NPROCS = 10 CLASS = D
c  
c  
c  This file is generated automatically by the setparams utility.
c  It sets the number of processors and the class of the NPB
c  in this directory. Do not modify it by hand.
c  
        character class
        parameter (class='D')
        integer num_procs
        parameter (num_procs=10)
        integer x_zones, y_zones
        parameter (x_zones=4, y_zones=4)
        integer gx_size, gy_size, gz_size
        parameter (gx_size=1632, gy_size=1216, gz_size=34)
        integer problem_size
        parameter (problem_size = 408)
        integer max_xysize, max_xybcsize
        parameter (max_xysize=248672, max_xybcsize=14180)
        integer max_numzones
        parameter (max_numzones=2)

c number of iterations and how often to print the norm
        integer itmax_default, inorm_default
        parameter (itmax_default=300, inorm_default=300)
        double precision dt_default, ratio
        parameter (dt_default = 1.0d0, ratio = 1.d0)
        logical  convertdouble
        parameter (convertdouble = .false.)
        character compiletime*11
        parameter (compiletime='04 Mar 2012')
        character npbversion*3
        parameter (npbversion='3.1')
        character cs1*6
        parameter (cs1='mpif77')
        character cs2*6
        parameter (cs2='$(F77)')
        character cs3*23
        parameter (cs3='-L/usr/local/lib -lmpi ')
        character cs4*20
        parameter (cs4='-I/usr/local/include')
        character cs5*28
        parameter (cs5='-O3 -fopenmp -mcmodel=medium')
        character cs6*28
        parameter (cs6='-O3 -fopenmp -mcmodel=medium')
        character cs7*6
        parameter (cs7='randi8')
