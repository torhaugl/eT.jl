PATH=$2:$PATH # prepend cmake to path
./setup.py -clean -lc $1/libcint/install/ -cmake-flags="-DCMAKE_MAKE_PROGRAM=$3"
