%Compile loss
cd('ADMM/Losses');
mex -O -largeArrayDims mexComputeEpsilon.c -lmwblas -lmwlapack
mex -O -largeArrayDims mexComputeEta.c -lmwblas -lmwlapack
mex -O -largeArrayDims mexFinishW.c -lmwblas -lmwlapack

%Compile ADMM helpers
cd('..');
mex -O -largeArrayDims mexUpdateHelper.c -lmwblas -lmwlapack

%Go back
cd('..');