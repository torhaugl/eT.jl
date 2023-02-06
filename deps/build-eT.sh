PATH=$2:$PATH # prepend cmake to path
MATH_ROOT=$4
cd eT
git checkout development
./setup.py -clean -lc $1 -cmake-flags="-DCMAKE_MAKE_PROGRAM=$3"
cd build
$2/cmake --build .
