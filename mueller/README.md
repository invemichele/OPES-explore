Software used is PLUMED v2.8 with OPES and VES modules enabled

`./configure --enable-modules=+opes+ves`

The VES module is needed for running the langevin dynamics, see [ves_md_linearexpansion](https://www.plumed.org/doc-master/user-doc/html/ves_md_linearexpansion.html)

For size reasons, KERNELS and STATE files are not present, and only one line every 50 is kept in COLVAR.
Most of the postprocessing is done via shell and python scripts, the jupyter notebook can be used to reproduce the figures of the paper.
