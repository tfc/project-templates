use anyhow::Result;
use clap::Parser;
use hasher::{format_hash_output, sha256_file};
use std::fs;
use std::path::PathBuf;

#[derive(Parser)]
#[command(name = "hash-folder")]
#[command(about = "Calculate SHA256 hash of all files in a folder using OpenSSL")]
struct Args {
    #[arg(help = "Path to the folder to hash")]
    folder: PathBuf,

    #[arg(short, long, help = "Process subdirectories recursively")]
    recursive: bool,
}

fn process_directory(dir: &PathBuf, recursive: bool) -> Result<Vec<(String, String)>> {
    let mut results = Vec::new();

    let entries = fs::read_dir(dir)?;

    for entry in entries {
        let entry = entry?;
        let path = entry.path();

        if path.is_file() {
            match sha256_file(&path) {
                Ok(hash) => {
                    results.push((path.display().to_string(), hash));
                }
                Err(e) => {
                    eprintln!("❌ Error hashing {}: {}", path.display(), e);
                }
            }
        } else if path.is_dir() && recursive {
            let mut sub_results = process_directory(&path, recursive)?;
            results.append(&mut sub_results);
        }
    }

    Ok(results)
}

fn main() -> Result<()> {
    let args = Args::parse();

    if !args.folder.is_dir() {
        anyhow::bail!("Path is not a directory: {}", args.folder.display());
    }

    println!(
        "🔒 Calculating SHA256 hashes for folder: {}",
        args.folder.display()
    );
    if args.recursive {
        println!("📁 Processing recursively...");
    }
    println!();

    let results = process_directory(&args.folder, args.recursive)?;

    if results.is_empty() {
        println!("📭 No files found in the specified directory.");
    } else {
        for (path, hash) in &results {
            println!("{}", format_hash_output(path, hash));
        }
        println!("\n🎉 Processed {} files", results.len());
    }

    Ok(())
}
