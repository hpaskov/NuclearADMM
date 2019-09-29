%Compile loss
cd('ADMM/Losses');
mex -O -largeArrayDims CFLAGS="\$CFLAGS -fopenmp" LDFLAGS="\$LDFLAGS -fopenmp" mexComputeEpsilon.c -lmwblas -lmwlapack
mex -O -largeArrayDims CFLAGS="\$CFLAGS -fopenmp" LDFLAGS="\$LDFLAGS -fopenmp" mexComputeEta.c -lmwblas -lmwlapack
mex -O -largeArrayDims CFLAGS="\$CFLAGS -fopenmp" LDFLAGS="\$LDFLAGS -fopenmp" mexFinishW.c -lmwblas -lmwlapack

%Compile ADMM helpers
cd('..');
mex -O -largeArrayDims CFLAGS="\$CFLAGS -fopenmp" LDFLAGS="\$LDFLAGS -fopenmp" mexUpdateHelper.c -lmwblas -lmwlapack

%Go back
cd('..');