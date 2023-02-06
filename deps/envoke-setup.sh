PATH=$2:$PATH # prepend cmake to path
MATH_ROOT=$4
./setup.py -clean -lc $1 -cmake-flags="-DCMAKE_MAKE_PROGRAM=$3"
