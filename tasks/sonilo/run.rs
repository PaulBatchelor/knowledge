use std::io;

fn main() -> io::Result<()> {
    let input = io::stdin();

    for line in input.lines() {
        // TODO: error handling
        let line = line.unwrap();
        println!("you typed: {}", line.trim());
        let args: Vec<_> = line.split_whitespace().collect();
        println!("arg: {}", args[0]);
        if args[0] == "q" {
            break;
        }
    }

    Ok(())
}
