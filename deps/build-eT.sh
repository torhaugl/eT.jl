export PATH=$3:$PATH
export MATH_ROOT=$2

cd eT
git checkout development
./setup.py -clean -lc $1 -CC $3/gcc -CXX $3/g++ -FC $3/gfortran
cd build
cmake --build .
