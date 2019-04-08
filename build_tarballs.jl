# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "JuliaThriftBuilder"
version = v"0.2.0"

# Collection of sources required to build JuliaThriftBuilder
sources = [
    "https://github.com/tanmaykm/thrift.git" =>
    "ef6de66707eb6135402a73520deec3478d9e1ec7",

]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
cd thrift/
./bootstrap.sh
if [ $target != "x86_64-apple-darwin14" ] && [ $target != "x86_64-unknown-freebsd11.1" ]; then
    LDFLAGS="-static-libgcc -static-libstdc++"
    export LDFLAGS
fi
./configure --prefix=$prefix --host=$target --enable-tutorial=no --enable-tests=no --enable-libs=no --disable-werror
make install

"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Linux(:i686, libc=:glibc),
    Linux(:x86_64, libc=:glibc),
    Linux(:aarch64, libc=:glibc),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf),
    Linux(:powerpc64le, libc=:glibc),
    Linux(:i686, libc=:musl),
    Linux(:x86_64, libc=:musl),
    Linux(:aarch64, libc=:musl),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf),
    MacOS(:x86_64),
    FreeBSD(:x86_64)
]

# The products that we will ensure are always built
products(prefix) = [
    ExecutableProduct(prefix, "thrift", :thrift)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    "https://github.com/tanmaykm/BisonBuilder/releases/download/v3.0.5/build_BisonBuilder.v1.0.0.jl"
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)
