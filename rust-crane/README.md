# SHA256 Hasher Demo

A simple Rust project demonstrating SHA256 file hashing using OpenSSL.

## Project Structure

- `hasher/` - Library crate with SHA256 hashing functionality
- `hash-file/` - Binary to hash a single file
- `hash-folder/` - Binary to hash all files in a folder

## Usage

### Hash a single file:
```bash
cargo run --bin hash-file -- test-file.txt
```

### Hash all files in a folder:
```bash
cargo run --bin hash-folder -- .
```

### Hash folder recursively:
```bash
cargo run --bin hash-folder -- . --recursive
```

## Dependencies

- OpenSSL for SHA256 hashing
- clap for CLI argument parsing
- anyhow for error handling
