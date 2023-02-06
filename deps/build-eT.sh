PATH=$2:$PATH
MATH_ROOT=$4

cd eT
git checkout development
./setup.py -clean -lc $1 -cmake-flags="-DCMAKE_MAKE_PROGRAM=$3" -CC $5/gcc -CXX $5/g++ -FC $5/gfortran
cd build
$2/cmake --build .
