const Self = @This();

mean: f64,
stdev: f64,
sample_info: ?struct {
    data: []const f64,
},

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

const stats = @import("../stats.zig");
const std = @import("std");
