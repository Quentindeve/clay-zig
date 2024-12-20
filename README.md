# Clay package for Zig

This is a simple package for the [Clay single-header library](https://github.com/nicbarker/clay).

## Add to project

Simply do

```bash
$ zig fetch --save https://github.com/Quentindeve/clay-zig
```

Then add to your build script:

```zig
...
const exe = b.addExecutable(.{...});

const clay = b.dependency("clay", .{
    .target = target,
    .optimize = optimize,
});

exe.addModule("clay", clay.module("clay"));
exe.linkLibrary(clay.artifact("clay"));
```