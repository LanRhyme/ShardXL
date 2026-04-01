# ShardXL-Lib FFI Directory

Place the compiled Rust dynamic library in this directory:

- **Windows**: `lighty_launcher.dll`
- **Linux**: `liblighty_launcher.so`
- **macOS**: `liblighty_launcher.dylib`

To build the library:
```bash
cd external/ShardXL-Lib
cargo build --release
```

Then copy the output file to this directory.
