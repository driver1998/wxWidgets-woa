HOST=$ARCH-w64-mingw32
PREFIX=$PWD/$HOST

export MINGW_ROOT=$PWD/$(find llvm-mingw* -maxdepth 1 -type d | head -n 1)
export PATH=$PATH:$MINGW_ROOT/bin
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$PREFIX/lib/pkgconfig

export CFLAGS="-DPNG_ARM_NEON_OPT=0 -DwxUSE_DBGHELP=0 -Wno-ignored-attributes \
               -Wno-unused-function -Wno-unused-const-variable -Wno-unused-const-variable"
export CXXFLAGS=$CFLAGS

echo Building for $HOST

# wxwidgets
pushd $(find wxWidgets* -maxdepth 1 -type d | head -n 1)
dos2unix include/wx/msw/wx.rc
for p in ../patches/*.patch; do patch -p1 < "$p"; done
unix2dos include/wx/msw/wx.rc
./configure --prefix=$PREFIX --host=$HOST --enable-shared --enable-monolithic --without-opengl || exit 1
make -j $(nproc) || exit 1
make install     || exit 1
popd

# let wx-config report its prefix based on its location
# instead of hardcoded to /home/appveyor/...
sed -i -r 's/(\$\{this_prefix:-).*?(\}\})$/\1$(realpath \"$(dirname \"$0\")\/..\")\2/g' $PREFIX/lib/wx/config/$HOST-msw-unicode-3.0

# fix symlinks
pushd $PREFIX/bin
rm wx-config
ln -s ../lib/wx/config/$HOST-msw-unicode-3.0 wx-config
popd

find $PREFIX
