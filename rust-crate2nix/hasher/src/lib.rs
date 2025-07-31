use anyhow::{Context, Result};
use openssl::hash::{MessageDigest, hash};
use std::fs::File;
use std::io::{BufReader, Read};
use std::path::Path;

pub fn sha256_file<P: AsRef<Path>>(path: P) -> Result<String> {
    let path = path.as_ref();
    let file =
        File::open(path).with_context(|| format!("Failed to open file: {}", path.display()))?;

    let mut reader = BufReader::new(file);
    let mut buffer = Vec::new();
    reader
        .read_to_end(&mut buffer)
        .with_context(|| format!("Failed to read file: {}", path.display()))?;

    let digest = hash(MessageDigest::sha256(), &buffer).context("Failed to compute SHA256 hash")?;

    Ok(hex::encode(digest))
}

pub fn format_hash_output(path: &str, hash: &str) -> String {
    format!("✓ {path} → {hash}")
}
