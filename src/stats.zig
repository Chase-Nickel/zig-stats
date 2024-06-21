// TODO:
//     - Tests
//     - Median & mode function without allocation?

pub const dist = @import("dist.zig");
pub const @"test" = @import("test.zig");

/// Return the mean of a dataset
/// Expects T to be a floating point type
/// Expects data to be a slice of a numeric type
pub fn mean(comptime T: type, data: anytype) T {
    if (@typeInfo(T) != .Float) unreachable;
    const data_type_info = @typeInfo(@TypeOf(data));
    if (data_type_info != .Slice) unreachable;
    const element_type_info = @typeInfo(@TypeOf(data_type_info.Slice.child));

    const n: T = @floatFromInt(data.len);
    var total: T = 0;
    for (data) |elem| {
        total += switch (element_type_info) {
            .Int => @floatFromInt(elem),
            .Float => @floatCast(elem),
            else => unreachable,
        };
    }
    return total / n;
}

/// Return the standard deviation of a sample
/// Expects T to be a floating point type
/// Expects data to be a slice of a numeric type
pub fn sampleStdev(comptime T: type, data: anytype) T {
    if (@typeInfo(T) != .Float) unreachable;
    const data_type_info = @typeInfo(@TypeOf(data));
    if (data_type_info != .Slice) unreachable;
    const element_type_info = @typeInfo(@TypeOf(data_type_info.Slice.child));

    const xbar = mean(T, data);
    var total: T = 0;
    for (data) |elem| {
        const x: T = switch (element_type_info) {
            .Int => @floatFromInt(elem),
            .Float => @floatCast(elem),
            else => unreachable,
        };
        const deviation = x - xbar;
        total += std.math.pow(T, deviation, 2.0);
    }

    const n: T = @floatFromInt(data.len);
    return std.math.sqrt(total) / (n - 1.0);
}

/// Return the standard deviation of a sample
/// Expects T to be a floating point type
/// Expects data to be a slice of a numeric type
pub fn populationStdev(comptime T: type, data: anytype) T {
    if (@typeInfo(T) != .Float) unreachable;
    const data_type_info = @typeInfo(@TypeOf(data));
    if (data_type_info != .Slice) unreachable;
    const element_type_info = @typeInfo(@TypeOf(data_type_info.Slice.child));

    const xbar = mean(T, data);
    var total: T = 0;
    for (data) |elem| {
        const x: T = switch (element_type_info) {
            .Int => @floatFromInt(elem),
            .Float => @floatCast(elem),
            else => unreachable,
        };
        const deviation = x - xbar;
        total += std.math.pow(T, deviation, 2.0);
    }

    const n: T = @floatFromInt(data.len);
    return std.math.sqrt(total) / n;
}

/// Return the mode of a dataset
pub fn mode(allocator: std.mem.Allocator, comptime T: type, data: []T) T {
    switch (@typeInfo(T)) {
        .Float, .Int => {},
        else => unreachable,
    }
    var map: std.AutoArrayHashMapUnmanaged(T, usize) = .{};
    defer map.deinit(allocator);
    for (data) |x| {
        const count: usize = map.get(x) orelse 0;
        try map.put(allocator, x, count + 1);
    }
    return map.keys()[std.mem.indexOfMax(usize, map.values())];
}

/// Return the median of a dataset
/// Expects T to be a floating point type
/// Expects data to be a slice of a numeric type
pub fn median(allocator: std.mem.Allocator, comptime T: type, data: anytype) T {
    if (@typeInfo(T) != .Float) unreachable;
    const data_type_info = @typeInfo(@TypeOf(data));
    if (data_type_info != .Slice) unreachable;
    const ElementType = @TypeOf(data_type_info.Slice.child);
    const element_type_info = @typeInfo(ElementType);

    const data_sorted = allocator.dupe(ElementType, data);
    defer allocator.free(data_sorted);
    std.mem.sort(ElementType, data_sorted, .{}, struct {
        fn sortFn(ctx: anytype, lhs: ElementType, rhs: ElementType) bool {
            _ = ctx;
            return lhs < rhs;
        }
    }.sortFn);

    if (data.len % 2 == 0) {
        const left: T, const right: T = switch (element_type_info) {
            .Float => .{
                @floatCast(data_sorted[data.len / 2 - 1]),
                @floatCast(data_sorted[data.len / 2]),
            },
            .Int => .{
                @floatFromInt(data_sorted[data.len / 2 - 1]),
                @floatFromInt(data_sorted[data.len / 2]),
            },
            else => unreachable,
        };
        return (left + right) / 2.0;
    }
    return switch (element_type_info) {
        .Float => @floatCast(data_sorted[data.len / 2]),
        .Int => @floatFromInt(data_sorted[data.len / 2]),
        else => unreachable,
    };
}

const std = @import("std");
