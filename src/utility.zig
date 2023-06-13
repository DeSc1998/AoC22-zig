const std = @import("std");

pub fn Stack(comptime T: type) type {
    return struct {
        stack: inner_stack,
        allocator: std.mem.Allocator,

        const inner_stack = std.atomic.Stack(T);
        const node = inner_stack.Node;
        pub const Self = @This();

        pub fn init(allocator: std.mem.Allocator) Self {
            return .{ .stack = inner_stack.init(), .allocator = allocator };
        }

        pub fn push(self: *Self, value: T) !void {
            var n = try self.allocator.create(node);
            n.data = value;
            self.stack.push(n);
        }

        pub fn peek(self: *Self) ?*T {
            if (self.stack.pop()) |n| {
                var tmp = &n.data;
                self.stack.push(n);
                return tmp;
            } else {
                return null;
            }
        }

        pub fn pop(self: *Self) ?T {
            if (self.stack.pop()) |n| {
                var tmp = n.data;
                self.allocator.destroy(n);
                return tmp;
            } else {
                return null;
            }
        }

        pub fn deinit(self: *Self) void {
            while (self.stack.pop()) |n| {
                self.allocator.destroy(n);
            }
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
