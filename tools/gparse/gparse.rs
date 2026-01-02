use std::io;
use std::io::prelude::*;
use std::fs;
use std::collections::{BTreeMap, HashMap, BTreeSet};
use std::error::Error;
use std::env;
use fs::File;
use std::io::BufReader;

type EdgeSet = BTreeSet<(String, String)>;
type NodeMap = BTreeMap<String, String>;
type NameMap = HashMap<String, String>;

fn load_nodes(filename: &str, mut nodes: NodeMap) -> Result<NodeMap, Box<dyn Error>> {
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

fn load_names(filename: &str, mut names: NameMap) -> Result<NameMap, Box<dyn Error>> {
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

fn load_edges(filename: &str, mut con: EdgeSet) -> Result<EdgeSet, Box<dyn Error>> {
    let data = fs::read(filename)?;
    let str = match String::from_utf8(data) {
        Ok(s) => s,
        Err(_) => panic!("oops"),
    };

    for line in str.lines() {
        let vals: Vec<_> = line.split_whitespace().collect();

        for i in 1..vals.len() {
            con.insert((vals[i].to_lowercase(), vals[0].to_lowercase()));
        }
    }

    Ok(con)
}

fn main() -> io::Result<()> {
    let args: Vec<String> = env::args().collect();

    if args.len() < 3 {
        panic!("usage: {} namespace page", args[0]);
    }


    let namespace = args[1].clone();
    let pagesfile = args[2].clone();

    let fp = File::open(pagesfile)?;
    let pages = BufReader::new(fp);

    let mut edges = EdgeSet::new();
    let mut nodes = NodeMap::new();
    let mut names = NameMap::new();

    for pg in pages.lines() {
        if let Some(pg) = pg.ok() {
            let nodes_file = format!("{}/{}.nodes", pg, pg);
            let names_file = format!("{}/{}.names", pg, pg);
            let edges_file = format!("{}/{}.edges", pg, pg);

            nodes = load_nodes(&nodes_file, nodes).unwrap();
            names = load_names(&names_file, names).unwrap();
            edges = load_edges(&edges_file, edges).unwrap();
        }

    }

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
        println!("co {} {}", b, a);
    }

    Ok(())
}
