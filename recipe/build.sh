#!/usr/bin/env bash
set -ex

# Workaround for https://github.com/conda-forge/gazebo-feedstock/pull/150
# Remove when boost is updated to 1.80.0
if [[ "${target_platform}" == "osx-64" ]]; then
  export CXXFLAGS="-DBOOST_ASIO_DISABLE_STD_ALIGNED_ALLOC ${CXXFLAGS}"
fi

cmake \
    ${CMAKE_ARGS} \
    -B _build -G Ninja \
    -DSCINE_MARCH="" \
    -DSCINE_USE_INTEL_MKL=OFF \
    -DSCINE_USE_STATIC_LINALG=OFF \
    -DCMAKE_BUILD_TYPE=Release \
    -DBLA_VENDOR=Generic

cmake --build _build
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" == "0" ]]; then
  ctest --test-dir _build --output-on-failure \
    -E "(SoluteSolventComplexTest.DoesAdditionOfMixedSolventsWork|UnitCellGeometryOptimizerTests.MixedOptimizer)"
fi
cmake --install _build
