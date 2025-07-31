use anyhow::Result;
use clap::Parser;
use hasher::{format_hash_output, sha256_file};
use std::path::PathBuf;

#[derive(Parser)]
#[command(name = "hash-file")]
#[command(about = "Calculate SHA256 hash of a file using OpenSSL")]
struct Args {
    #[arg(help = "Path to the file to hash")]
    file: PathBuf,
}

fn main() -> Result<()> {
    let args = Args::parse();

    println!("🔒 Calculating SHA256 hash...");

    let hash = sha256_file(&args.file)?;
    let output = format_hash_output(&args.file.display().to_string(), &hash);

    println!("{output}");

    Ok(())
}
