%Compile loss
cd('ADMM/Losses');
mex -O COMPFLAGS="$COMPFLAGS /openmp" -largeArrayDims mexComputeEpsilon.c -lmwblas -lmwlapack
mex -O COMPFLAGS="$COMPFLAGS /openmp" -largeArrayDims mexComputeEta.c -lmwblas -lmwlapack
mex -O COMPFLAGS="$COMPFLAGS /openmp" -largeArrayDims mexFinishW.c -lmwblas -lmwlapack

%Compile ADMM helpers
cd('..');
mex -O COMPFLAGS="$COMPFLAGS /openmp" -largeArrayDims mexUpdateHelper.c -lmwblas -lmwlapack

%Go back
cd('..');