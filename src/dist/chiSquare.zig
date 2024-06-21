//! Chi squared distribution

const Self = @This();

/// Degrees of freedom
df: f64,

/// Initialize a Chi-squared distribution from one variable sample data
pub fn fromSampleOneVar(sample: []const usize) Self {
    const category_count: f64 = @floatFromInt(sample.len);
    return .{
        .df = category_count - 1.0,
    };
}

/// Initialize a Chi-squared distribution from two variable sample data
pub fn fromSampleTwoVar(sample: []const []const usize) Self {
    const category1_count: f64 = @floatFromInt(sample.len);
    const category2_count: f64 = @floatFromInt(sample[0].len);
    return .{
        .df = (category1_count - 1.0) * (category2_count - 1.0),
    };
}

/// Initialize a Chi-squared distribution from distribution parameters
pub fn fromParameters(degrees_of_freedom: f64) Self {
    return .{
        .df = degrees_of_freedom,
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
