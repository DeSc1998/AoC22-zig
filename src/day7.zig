const std = @import("std");
const util = @import("utility.zig");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

// TODO: types might be a bit overengineered for this day
fn Entry(comptime F: type, comptime D: type) type {
    return union(enum) {
        file: F,
        directory: D,
    };
}

const File = struct {
    name: []const u8,
    size: usize,
};

const Directory = struct {
    name: []const u8,
    entries: std.StringHashMap(Entry(File, Directory)),
};

const Stack = util.Stack(*Directory);
const Entries = std.StringHashMap(Entry(File, Directory));

fn splitByCommands(input: []const u8, out: *std.ArrayList([]const u8)) !void {
    var splitter = std.mem.splitSequence(u8, input, "$ ");
    while (splitter.next()) |line| {
        try out.append(line);
    }
}

fn parseFile(input: []const u8) !File {
    var splitter = std.mem.splitAny(u8, input, " ");
    const size = try std.fmt.parseInt(usize, splitter.next().?, 10);
    const name = splitter.next().?;
    return .{
        .name = name,
        .size = size,
    };
}

fn parseDirectory(input: []const u8) Directory {
    var splitter = std.mem.splitAny(u8, input, " ");
    _ = splitter.next(); // ignore 'dir'
    const name = splitter.next().?;
    return .{
        .name = name,
        .entries = Entries.init(allocator),
    };
}

fn findDirByName(name: []const u8, entries: Entries) ?*Directory {
    var iter = entries.iterator();
    while (iter.next()) |map_entry| {
        if (std.mem.eql(u8, name, map_entry.key_ptr.*)) {
            switch (map_entry.value_ptr.*) {
                .directory => |*dir| {
                    return dir;
                },
                .file => {},
            }
        }
    }
    return null;
}

fn sizeOfDirectory(dir: Directory) u64 {
    var iter = dir.entries.iterator();
    var total_size: u64 = 0;
    while (iter.next()) |map_entry| {
        switch (map_entry.value_ptr.*) {
            .directory => |d| {
                total_size += sizeOfDirectory(d);
            },
            .file => |f| {
                total_size += f.size;
            },
        }
    }

    return total_size;
}

fn mapDirectorySize(root: Directory, map: *std.ArrayList(File)) !void {
    const root_size = sizeOfDirectory(root);
    try map.append(.{ .name = root.name, .size = root_size });
    var iter = root.entries.iterator();
    while (iter.next()) |entry| {
        switch (entry.value_ptr.*) {
            .directory => |dir| {
                try mapDirectorySize(dir, map);
            },
            .file => {},
        }
    }
}

fn addToTop(stack: Stack, name: []const u8, entry: Entry) !void {
    const top = if (stack.peek()) |dir| dir else return error.StackEmpty;
    try top.*.entries.put(name, entry);
}

fn collectEntries(raw_entries: std.ArrayList([]const u8), dir: *Directory) !void {
    for (raw_entries.items[1 .. raw_entries.items.len - 1]) |item| { // ignore 'ls'
        const entry: Entry(File, Directory) =
            if (std.mem.startsWith(u8, item, "dir"))
            .{ .directory = parseDirectory(item) }
        else
            .{ .file = try parseFile(item) };

        const name = switch (entry) {
            .directory => |d| d.name,
            .file => |f| f.name,
        };
        try dir.entries.put(name, entry);
    }
}

fn parse(input: []const u8) !Directory {
    var commands = std.ArrayList([]const u8).init(std.heap.page_allocator);
    var dir_stack: Stack = Stack.init(allocator);
    var root: Directory = .{ .name = "/", .entries = Entries.init(allocator) };

    defer commands.deinit();
    defer dir_stack.deinit();

    try splitByCommands(input, &commands);

    for (commands.items[1..]) |command| { // ignore 'cd /'
        if (std.mem.startsWith(u8, command, "cd /")) {
            dir_stack.deinit();
            dir_stack = Stack.init(allocator);
            try dir_stack.push(&root);
        } else if (std.mem.startsWith(u8, command, "cd ..")) {
            _ = dir_stack.pop();
        } else if (std.mem.startsWith(u8, command, "cd")) {
            var s = std.mem.splitAny(u8, command[3..], " "); // ignore 'cd '
            const dest = s.next().?;
            const curr = dir_stack.peek().?.*;
            if (findDirByName(dest[0 .. dest.len - 1], curr.entries)) |dir| {
                try dir_stack.push(dir);
            } else {
                return error.DirectoryDoesNotExist;
            }
        } else if (std.mem.startsWith(u8, command, "ls")) {
            var entries = std.ArrayList([]const u8).init(allocator);
            defer entries.deinit();

            try util.splitByLines(command, &entries);
            const dir = dir_stack.peek().?;
            try collectEntries(entries, dir);
        } else {
            return error.UnkownCommand;
        }
    }

    return root;
}

fn getIndent(level: u32) ![]const u8 {
    const buffer = try allocator.alloc(u8, level * 2);
    for (buffer) |*item| {
        item.* = ' ';
    }
    return buffer;
}

fn printDirectory(dir: Directory, indent: u32) !void {
    const indentation = try getIndent(indent);
    defer allocator.free(indentation);
    var iter = dir.entries.iterator();
    while (iter.next()) |map_entry| {
        switch (map_entry.value_ptr.*) {
            .directory => |d| {
                std.debug.print("{s}{s}:\n", .{ indentation, d.name });
                try printDirectory(d, indent + 1);
            },
            .file => |f| {
                // zig fmt: off
                std.debug.print(
                    "{s}{s}: {}\n",
                    .{
                        indentation, 
                        f.name, 
                        f.size });
                // zig fmt: on
            },
        }
    }
}

pub fn solve1(input: []const u8) !u64 {
    var map = std.ArrayList(File).init(allocator);

    const root = try parse(input);
    try mapDirectorySize(root, &map);

    var total_sizes: u64 = 0;
    for (map.items) |mapping| {
        if (mapping.size <= 100_000) {
            total_sizes += mapping.size;
        }
    }
    return total_sizes;
}

fn lessThan(_: @TypeOf(.{}), left: File, right: File) bool {
    return left.size < right.size;
}

pub fn solve2(input: []const u8) !u64 {
    var map = std.ArrayList(File).init(allocator);
    const root = try parse(input);
    const root_size = sizeOfDirectory(root);
    const unused: u64 = 70_000_000 - root_size;
    const update_size: u64 = 30_000_000;
    try mapDirectorySize(root, &map);
    std.mem.sort(File, map.items, .{}, lessThan);
    var dir_size: u64 = undefined;
    for (map.items) |item| {
        if (update_size <= unused + item.size) {
            dir_size = item.size;
            break;
        }
    }
    return dir_size;
}

test "day-7" {
    const input =
        \\$ cd /
        \\$ ls
        \\dir a
        \\14848514 b.txt
        \\8504156 c.dat
        \\dir d
        \\$ cd a
        \\$ ls
        \\dir e
        \\29116 f
        \\2557 g
        \\62596 h.lst
        \\$ cd e
        \\$ ls
        \\584 i
        \\$ cd ..
        \\$ cd ..
        \\$ cd d
        \\$ ls
        \\4060174 j
        \\8033020 d.log
        \\5626152 d.ext
        \\7214296 k
        \\
    ;

    const total_sizes = try solve1(input);

    try std.testing.expectEqual(@as(u64, 95_437), total_sizes);
}
