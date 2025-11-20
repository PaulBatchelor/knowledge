use std::io;
use std::fs;
use std::collections::{BTreeMap, HashMap, BTreeSet};
use std::error::Error;

fn load_nodes(filename: &str) -> Result<BTreeMap<String, String>, Box<dyn Error>> {
    let mut nodes: BTreeMap<String, String> = BTreeMap::new();
    let data = fs::read(filename)?;
    let str = match String::from_utf8(data) {
        Ok(s) => s,
        Err(_) => panic!("oops"),
    };

    let str = str.replace("\n", " ");

    let tokens = str.split("@");

    for tok in tokens.skip(1) {
        if let Some(vals) = tok.split_once(" ") {
            //println!("{}: {}", vals.0, vals.1.trim());
            nodes.insert(vals.0.to_lowercase(), vals.1.trim().to_string());
        }
    }

    Ok(nodes)
}

fn load_names(filename: &str) -> Result<HashMap<String, String>, Box<dyn Error>> {
    let mut names: HashMap<String, String> = HashMap::new();
    let data = fs::read(filename)?;
    let str = match String::from_utf8(data) {
        Ok(s) => s,
        Err(_) => panic!("oops"),
    };

    for line in str.lines() {
        if let Some(vals) = line.split_once(" ") {
            names.insert(vals.0.to_lowercase(), vals.1.to_string());
        }
    }
    
    Ok(names)
}

fn load_edges(filename: &str) -> Result<BTreeSet<(String, String)>, Box<dyn Error>> {
    let data = fs::read(filename)?;
    let str = match String::from_utf8(data) {
        Ok(s) => s,
        Err(_) => panic!("oops"),
    };
    let mut con = BTreeSet::new();

    for line in str.lines() {
        let vals: Vec<_> = line.split_whitespace().collect();

        for i in 1..vals.len() {
            con.insert((vals[i].to_lowercase(), vals[0].to_lowercase()));
        }
    }

    Ok(con)
}

fn main() -> io::Result<()> {
    let namespace = "dmoi/notes";
    let page = "05h";
    let nodes_file = format!("{}.nodes", page);
    let names_file = format!("{}.names", page);
    let edges_file = format!("{}.edges", page);
    let nodes = load_nodes(&nodes_file).unwrap();
    let names = load_names(&names_file).unwrap();
    let edges = load_edges(&edges_file).unwrap();

    println!("ns {}", namespace);
    for (key, val) in nodes {
        let name = names.get(&key).unwrap_or(&key);
        println!("nn {}", name);
        println!("ln {}", val);
        println!("at id {}", key);
    }

    for edge in edges {
        let a = names.get(&edge.0).unwrap_or(&edge.0);
        let b = names.get(&edge.1).unwrap_or(&edge.1);
        println!("co {} {}", a, b);
    }

    Ok(())
}
