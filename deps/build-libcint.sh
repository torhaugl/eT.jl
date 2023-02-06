cd $1
mkdir build
cd build

$2/cmake .. -DBUILD_SHARED_LIBS=0 -DPYPZPX=1 -DCMAKE_INSTALL_PREFIX=../install -GNinja -DCMAKE_MAKE_PROGRAM=$3 -DCMAKE_C_COMPILER=$4/gcc
$2/cmake --build . --target install
