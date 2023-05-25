const std = @import("std");

pub fn readEntireFile(file_path: []const u8, allocator: std.mem.Allocator) ![]u8 {
    var dir = std.fs.cwd();
    const file = try dir.openFile(file_path, .{});
    defer file.close();
    const stat = try file.stat();
    return try dir.readFileAlloc(allocator, file_path, stat.size);
}

pub fn collect(comptime T: type, splitter: *std.mem.SplitIterator(T), out: *std.ArrayList([]const T)) !void {
    while (splitter.next()) |next_val| {
        try out.append(next_val);
    }
}

pub fn splitByLines(content: []const u8, out: *std.ArrayList([]const u8)) !void {
    var splitter = std.mem.split(u8, content, "\n");
    try collect(u8, &splitter, out);
}
