#ifndef _SVM_MISC_H_
#define _SVM_MISC_H_

#include <cstdio>
#include <cstdlib>
#include <cstddef>
#include <cstdint>
#include <cstring>
#include <algorithm>
#include <cassert>
#include <thread>
#include <map>
#include <set>
#include <limits>
#include <zlib.h>
#include <iostream>
#include <fstream>
#include "blaze/Math.h"
#include "logutil.h"
#include "klib/kstring.h"


#ifdef __GNUC__
#  define likely(x) __builtin_expect((x),1)
#  define unlikely(x) __builtin_expect((x),0)
#  define UNUSED(x) __attribute__((unused)) x
#else
#  define likely(x) (x)
#  define unlikely(x) (x)
#  define UNUSED(x) (x)
#endif

#ifndef INLINE
#  if __GNUC__ || __clang__
#  define INLINE __attribute__((always_inline)) inline
#  else
#  define INLINE inline
#  endif
#endif

namespace svm {

using std::cerr;
using std::cout;

using std::size_t;
using u32 = std::uint32_t;
using u64 = std::uint64_t;
using blaze::DynamicVector;
using blaze::DynamicMatrix;

template<typename FloatType, typename MatrixType1, typename MatrixType2>
FloatType dot(MatrixType1 &a, MatrixType2 &b) {
    return static_cast<FloatType>(a * trans(b));
}

struct dims_t {
    size_t ns_, nd_;
    dims_t(size_t samples, size_t dimensions): ns_(samples), nd_(dimensions) {}
    dims_t(const char *fn);
};

#if 0
template<typename MatrixType, typename FloatType=float>
INLINE FloatType dot(MatrixType &a, MatrixType &b) {
    return inner(a, b);
}
#endif

template<typename MatrixType, typename FloatType=float>
INLINE FloatType diffnorm(MatrixType &a, MatrixType &b) {
    const auto norm(a - b);
    return dot(norm, norm);
}

} // namespace svm


#endif  // _SVM_MISC_H_
