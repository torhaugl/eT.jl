export PATH=$2:$PATH

cd $1
mkdir build
cd build

cmake .. -DBUILD_SHARED_LIBS=0 -DPYPZPX=1 -DCMAKE_INSTALL_PREFIX=../install -GNinja -DCMAKE_C_COMPILER=$2/gcc
cmake --build . --target install
