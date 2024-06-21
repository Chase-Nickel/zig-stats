const Self = @This();

mean: f64,
stdev: f64,

// Initialize a normal distribution from distribution parameters
pub fn fromParameters(mean: f64, stdev: f64) Self {
    return .{
        .mean = mean,
        .stdev = stdev,
        .sample_info = null,
    };
}

// Initialize a normal distribution from a sample
pub fn fromSample(sample: []const f64) Self {
    const mean = stats.mean(f64, sample);
    const stdev = stats.sampleStdev(f64, sample);
    return .{
        .mean = mean,
        .stdev = stdev,
        .sample_info = .{ .data = sample },
    };
}

pub fn median(self: Self) f64 {
    return self.mean;
}

pub fn mode(self: Self) f64 {
    return self.mean;
}

pub fn variance(self: Self) f64 {
    return self.stdev * self.stdev;
}

pub fn mad(self: Self) f64 {
    return self.stdev * @sqrt(2.0 / std.math.pi);
}

pub fn pdf(self: Self, x: f64) f64 {
    const coeff = common.sqrt1_tau * (1.0 / self.stdev);
    const exponent = -0.5 * std.math.pow(f64, (x - self.mean) / self.stdev, 2.0);
    return coeff * @exp(exponent);
}

pub fn cdf(self: Self, x: f64) f64 {
    return 0.5 * (1.0 + common.erf((x - self.mean) / (self.stdev * @sqrt(2))));
}

const common = @import("../common.zig");
const stats = @import("../stats.zig");
const std = @import("std");
