//! Chi squared hypothesis tests

/// Returns the p-value obtained by performing a Chi-squared Hypothesis Test
/// for Goodness of Fit Test
/// H0: The population distribution is uniformly distributed
/// Ha: The population distribution is not uniformly distributed
pub fn testGofUniform(sample: []const usize) f64 {
    const sample_len: f64 = @floatFromInt(sample.len);
    var n: f64 = 0.0;
    for (sample) |x| {
        n += @floatFromInt(x);
    }
    const expected = n / sample_len;
    var chi_square: f64 = 0.0;
    for (sample) |x| {
        const observed: f64 = @floatFromInt(x);
        const diff = observed - expected;
        chi_square += diff * diff / expected;
    }
    const distribution = chiSquare.fromSampleOneVar(sample);
    return 1.0 - distribution.cdf(chi_square);
}

/// NOTE: NOT IMPLEMENTED
/// Returns the p-value obtained by performing a Chi-squared Hypothesis Test
/// for Independence Test
/// H0: The two variables are independent
/// Ha: The two variables are not independent
pub fn testIndependence(sample: []const []const f64) f64 {
    _ = sample;
    @compileError("Not implemented");
}

/// NOTE: NOT IMPLEMENTED
/// Returns the p-value obtained by performing a Chi-squared Hypothesis Test
/// for Homogeneity Test
/// H0: The two populations have the same distribution
/// Ha: The two populations do not have the same distribution
pub fn testHomogeneity(sample: []const []const f32) f64 {
    _ = sample;
    @compileError("Not implemented");
}

const chiSquare = @import("../dist/chiSquare.zig");
const std = @import("std");
