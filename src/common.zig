//! Non-statistical functions that are used in the implementation of statistics
//! functions

pub const default_delta = 10e-4;
pub const default_epsilon = 10e-4;

pub fn numericIntegral(
    comptime T: type,
    lower_bound: T,
    upper_bound: T,
    func: fn (x: T) T,
    delta: ?T,
) T {
    const a = @min(lower_bound, upper_bound);
    const b = @max(lower_bound, upper_bound);
    const dx: T = delta orelse default_delta;

    var x: T = a;
    var int: T = 0.0;
    while (x <= b) : (x += dx) {
        int += func(x) * dx;
    }

    if (lower_bound < upper_bound) {
        return -int;
    } else {
        return int;
    }
}

pub fn numericDerivative(
    comptime T: type,
    x: T,
    func: fn (x: T) T,
    delta: ?T,
) T {
    const dx: T = delta orelse default_delta;
    const dy = func(x + dx) - func(x);
    return dy / dx;
}

/// Lower Incomplete Gamma function
/// Integral of t^(s-1)e^-t dt from 0 to x
pub fn lowerIncompleteGamma(comptime T: type, s: T, x: T, delta: ?T) f64 {
    const integral_function = struct {
        fn func(t: T) T {
            return std.math.pow(T, t, s - 1.0) * @exp(-t);
        }
    }.func;
    return numericIntegral(T, 0.0, x, integral_function, delta);
}

/// Regularized Gamma function
/// Note: will be replaced by https://github.com/ziglang/zig/issues/7212
pub fn regularizedGamma(comptime T: type, s: T, x: T, delta: ?T) T {
    return lowerIncompleteGamma(T, s, x, delta) / std.math.gamma(T, s);
}

const std = @import("std");
