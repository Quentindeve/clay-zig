const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const lib = try compileClay(b, target, optimize);

    lib.installHeader(b.path("clay.h"), "clay.h");
    b.installArtifact(lib);
}

pub fn compileClay(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) !*std.Build.Step.Compile {
    try downloadClayHeader(b);

    const clay = b.addStaticLibrary(.{ .name = "clay", .target = target, .optimize = optimize });

    // Clay depends on Raylib, so we link it
    const raylib = b.dependency("raylib", .{ .target = target, .optimize = optimize });
    clay.linkLibrary(raylib.artifact("raylib"));

    const flags = &[_][]const u8{
        "-std=gnu99",
        "-DCLAY_IMPLEMENTATION",
    };

    const clayFile = b.path("clay.h");
    clay.addCSourceFile(.{ .file = clayFile, .flags = flags });

    return clay;
}

const CLAY_HEADER_GITHUB_LOCATION = "https://github.com/nicbarker/clay/releases/latest/download/clay.h";
pub fn downloadClayHeader(b: *std.Build) !void {
    const fs = std.fs;
    const http = std.http;

    const out_file = try fs.cwd().createFile("clay.h", .{});
    defer out_file.close();

    var buf: [8192]u8 = undefined;
    var client = http.Client{ .allocator = b.allocator };
    defer client.deinit();
    const uri = try std.Uri.parse(CLAY_HEADER_GITHUB_LOCATION);

    var request = try client.open(.GET, uri, .{ .server_header_buffer = &buf });
    defer request.deinit();

    try request.send();
    try request.finish();
    try request.wait();

    var buffer: [4096]u8 = undefined;

    while (true) {
        const bytesRead = request.read(&buffer) catch {
            return;
        };

        if (bytesRead == 0) return;

        _ = try out_file.write(buffer[0..bytesRead]);
    }
}
