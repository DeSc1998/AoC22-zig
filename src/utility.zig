const std = @import("std");

pub fn Stack(comptime T: type) type {
    return struct {
        stack: inner_stack,

        const inner_stack = std.ArrayList(T);
        pub const Self = @This();

        pub fn init(allocator: std.mem.Allocator) Self {
            return .{ .stack = inner_stack.init(allocator) };
        }

        pub fn push(self: *Self, value: T) !void {
            try self.stack.append(value);
        }

        pub fn peek(self: *Self) ?T {
            if (self.stack.items.len > 0) {
                return self.stack.items[self.stack.items.len - 1];
            } else {
                return null;
            }
        }

        pub fn pop(self: *Self) ?T {
            if (self.stack.items.len > 0) {
                return self.stack.pop();
            } else {
                return null;
            }
        }

        pub fn deinit(self: *Self) void {
            self.stack.deinit();
        }
    };
}

pub fn readEntireFile(file_path: []const u8, allocator: std.mem.Allocator) ![]u8 {
    var dir = std.fs.cwd();
    const file = try dir.openFile(file_path, .{});
    defer file.close();
    const stat = try file.stat();
    return try dir.readFileAlloc(allocator, file_path, stat.size);
}

pub fn collect(comptime T: type, splitter: *std.mem.SplitIterator(T, std.mem.DelimiterType.sequence), out: *std.ArrayList([]const T)) !void {
    while (splitter.next()) |next_val| {
        try out.append(next_val);
    }
}

pub fn splitByLines(content: []const u8, out: *std.ArrayList([]const u8)) !void {
    var splitter = std.mem.splitSequence(u8, content, "\n");
    try collect(u8, &splitter, out);
}
