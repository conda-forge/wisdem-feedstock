#!/bin/bash

set -eox pipefail

#export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$PREFIX/lib/pkgconfig:$BUILD_PREFIX/lib/pkgconfig

#EXTRA_FLAGS=""
#NP_INC="${SP_DIR}/numpy/core/include/"
echo "PYTHON TARGET=${PYTHON}"

if [ `uname` == Darwin ]; then
    export  LDFLAGS="$LDFLAGS  -Wl,-flat_namespace,-undefined,suppress"
fi

#if [[ $CONDA_BUILD_CROSS_COMPILATION == "1" ]]; then
    # Add pkg-config to cross-file binaries since meson will disable it
    # See https://github.com/mesonbuild/meson/issues/7276
    #echo "pkg-config = '$(which pkg-config)'" >> "$BUILD_PREFIX"/meson_cross_file.txt
    # Use Meson cross-file flag to enable cross compilation
    #EXTRA_FLAGS="--cross-file $BUILD_PREFIX/meson_cross_file.txt"
    #NP_INC=""
#fi

# This is done on two lines so that the command will return failure info if it fails
#PKG_CONFIG=$(which pkg-config)
#export PKG_CONFIG

#cd "${SRC_DIR}"

# MESON_ARGS is used within setup.py to pass extra arguments to meson
# We need these so that dependencies on the build machine are not incorrectly used by meson when building for a different target
#export MESON_ARGS="-Dincdir_numpy=${NP_INC} -Dpython_target=${PYTHON} ${MESON_ARGS}"
export MESON_ARGS="-Dpython_target=${PYTHON} ${MESON_ARGS}"

# We use this instead of pip install . because the way meson builds from within a conda-build process puts the build
# artifacts where pip install . can't find them. Here we explicitly build the wheel into the working director, wherever that is
# and then tell pip to install the wheel in the working directory. Also, python -m build is now the recommended way to build
# see https://packaging.python.org/en/latest/tutorials/packaging-projects/
$PYTHON -m build -n -x -w .
$PYTHON -m pip install --prefix "${PREFIX}" --no-deps dist/*.whl
#pip install --prefix "${PREFIX}" --no-deps --no-index --find-links dist pyoptsparse
#bin/rm -rf ${SP_DIR}/meson_build
