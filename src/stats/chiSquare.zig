const Self = @This();

/// Degrees of freedom
df: f64,

/// Information about the sample proved to .fromSample* functions
sample_info: ?union(enum) {
    one_variable: struct {
        data: []const usize,
        n: usize,
    },
    two_variable: struct {
        data: []const []const usize,
        n: usize,
    },
},

/// Initialize a Chi-squared distribution from one variable sample data
pub fn fromSampleOneVar(sample: []const usize) Self {
    var n: usize = 0;
    for (sample) |x| {
        n += x;
    }
    const category_count: f64 = @floatFromInt(sample.len);
    return .{
        .df = category_count - 1.0,
        .sample_info = .{
            .data = sample,
            .n = n,
        },
    };
}

/// Initialize a Chi-squared distribution from two variable sample data
pub fn fromSampleTwoVar(sample: []const []const usize) Self {
    var n: usize = 0;
    for (sample) |variable| {
        for (variable) |x| {
            n += x;
        }
    }
    const variable1_len: f64 = @floatFromInt(sample.len);
    const variable2_len: f64 = @floatFromInt(sample[0].len);
    return .{
        .df = (variable1_len - 1.0) * (variable2_len - 1.0),
        .sample_info = .{
            .data = sample,
            .n = n,
        },
    };
}

/// Initialize a Chi-squared distribution from distribution parameters
pub fn fromParameters(degrees_of_freedom: f64) Self {
    return .{
        .df = degrees_of_freedom,
        .sample_info = null,
    };
}

/// Probability distribution function for a Chi-squared distribution
pub fn pdf(self: Self, x: f64) f64 {
    if (x <= 0.0) {
        return 0.0;
    }
    return std.math.pow(f64, x, self.df / 2.0 - 1.0) * @exp(-self.df / 2.0) /
        std.math.pow(f64, 2.0, self.df / 2.0) * std.math.gamma(f64, self.df / 2.0);
}

/// Cumulative distribution function for a Chi-squared distribution
pub fn cdf(self: Self, x: f64) f64 {
    return calc.regularizedGamma(f64, self.df / 2.0, x / 2.0);
}

pub const TestError = error{DistributionNotFromSample};
pub const SingleVarTestError = TestError || error{MultiVarSample};
pub const MultiVarTestError = TestError || error{SingleVarSample};

/// Returns the p-value obtained by performing a Chi-squared Hypothesis Test
/// for Goodness of Fit Test
/// H0: The population distribution is uniformly distributed
/// Ha: The population distribution is not uniformly distributed
pub fn testGofUniform(self: Self) SingleVarTestError!f64 {
    const sample_info = self.sample_info orelse
        return SingleVarTestError.DistributionNotFromSample;
    const sample = switch (sample_info) {
        .one_variable => |s| s,
        .two_variable => return SingleVarTestError.MultivarSample,
    };

    const sample_len: f64 = @floatFromInt(sample.data.len);
    const n: f64 = @floatFromInt(sample.n);

    const expected = n / sample_len;
    var chi_square: f64 = 0.0;
    for (sample_info.data) |observed| {
        const o: f64 = @floatFromInt(observed);
        chi_square += std.math.pow(f64, o - expected, 2.0) / expected;
    }
    return 1.0 - self.cdf(chi_square);
}

/// NOTE: NOT IMPLEMENTED
/// Returns the p-value obtained by performing a Chi-squared Hypothesis Test
/// for Independence Test
/// H0: The two variables are independent
/// Ha: The two variables are not independent
pub fn testIndependence(self: Self) MultiVarTestError!f64 {
    const sample_info = self.sample_info orelse
        return MultiVarTestError.DistributionNotFromSample;
    const sample = switch (sample_info) {
        .one_variable => return MultiVarTestError.SingleVarSample,
        .two_variable => |s| s,
    };

    _ = sample;
    var chi_square: f64 = 0.0;
    _ = &chi_square;
    @compileError("Not implemented");
}

/// NOTE: NOT IMPLEMENTED
/// Returns the p-value obtained by performing a Chi-squared Hypothesis Test
/// for Homogeneity Test
/// H0: The two populations have the same distribution
/// Ha: The two populations do not have the same distribution
pub fn testHomogeneity(self: Self) MultiVarTestError!f64 {
    const sample_info = self.sample_info orelse
        return MultiVarTestError.DistributionNotFromSample;
    const sample = switch (sample_info) {
        .one_variable => return MultiVarTestError.SingleVarSample,
        .two_variable => |s| s,
    };

    _ = sample;
    var chi_square: f64 = 0.0;
    _ = &chi_square;
    @compileError("Not implemented");
}

/// Returns the mean (expected value) of a Chi-squared distribution
pub fn mean(self: Self) f64 {
    return self.df;
}

/// Returns an approximation of the median of a Chi-squared distribution
pub fn median(self: Self) f64 {
    return self.df * std.math.pow(f64, 1.0 - 2.0 / (9.0 * self.df), 3.0);
}

/// Returns the mode of a Chi-squared distribution
pub fn mode(self: Self) f64 {
    return @max(self.df - 2.0, 0.0);
}

/// Returns the variance of a Chi-squared distribution
pub fn variance(self: Self) f64 {
    return 2.0 * self.df;
}

/// Returns the standard deviation of a Chi-squared distribution
pub fn stdev(self: Self) f64 {
    return @sqrt(self.variance());
}

const calc = @import("../common.zig");
const std = @import("std");
