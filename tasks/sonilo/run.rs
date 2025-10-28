use std::io;
use std::io::prelude::*;
use std::io::BufReader;
use std::fs::File;
use std::collections::BTreeMap;
use std::env;

#[allow(dead_code)]
enum TaskState {
    TODO,
    DONE
}

impl Default for TaskState {
    fn default() -> TaskState {
        TaskState::TODO
    }
}

impl From<&TaskState> for String {
    fn from(x: &TaskState) -> String {
        match x {
            TaskState::TODO => return "TODO".to_string(),
            TaskState::DONE => return "DONE".to_string(),
        }
    }
}

impl From<&str> for TaskState {
    fn from(s: &str) -> TaskState {
        if s == "TODO" {
            return TaskState::TODO;
        } else if s == "DONE" {
            return TaskState::DONE;
        }
        TaskState::TODO
    }
}

#[derive(Default)]
#[allow(dead_code)]
struct Task {
    path: String,
    day: usize,
    state: TaskState,
}

#[derive(Default)]
#[allow(dead_code)]
struct State {
    tasks: Vec<Task>,
    schedule: BTreeMap<usize,Vec<usize>>,
    selected: usize,
    day: usize,
}

impl State {
    fn load_schedule(&mut self, filename: &str) {
        let f = match File::open(filename) {
            Ok(f) => f,
            Err(_) => {
                println!("Could not load file.");
                return;
            }
        };

        let reader = BufReader::new(f);

        self.tasks = Vec::new();
        for line in reader.lines() {
            match line {
                Ok(line) => {
                    let fields: Vec<_> = line.split(":").collect();
                    let state = if fields.len() >= 3 {
                        fields[2].into()
                    } else {
                        TaskState::default() 
                    };

                    let task = Task {
                        path: fields[0].to_string(),
                        day: fields[1].parse().unwrap_or_default(),
                        state,
                    };
                    self.tasks.push(task);
                }
                Err(_) => continue,
            };
        }
    }

    fn print_schedule(&self) {
        for (idx, task) in self.tasks.iter().enumerate() {
            let state: String = (&task.state).into();
            println!("{}\t{}\t{}\t{}", idx, task.path, task.day, state);
        }
    }

    fn save_schedule(&self, filename: &str) {
        let mut buffer = match File::create(filename) {
            Ok(f) => f,
            Err(_) => {
                println!("Could not open file for writing.");
                return;
            }
        };

        for task in &self.tasks {
            let state: String = (&task.state).into();
            let _ = write!(buffer, "{}:{}:{}\n", task.path, task.day, state);
        }
    }

    fn find_task(&self, keyword: &str) {
        for (idx, task) in self.tasks.iter().enumerate() {
            if task.path.contains(keyword) {
                let state: String = (&task.state).into();
                println!("{}\t{}\t{}\t{}", idx, task.path, task.day, state);
            }
        }
    }

    fn print_selected_task(&self) {
        let idx = self.selected;
        let task = &self.tasks[idx];
        let state: String = (&task.state).into();
        println!("{}\t{}\t{}\t{}", idx, task.path, task.day, state);
    }

    fn done(&mut self, idx: Option<usize>) {
        let idx = idx.unwrap_or_else(|| self.selected);
        self.tasks[idx].state = TaskState::DONE;
    }

    fn todo(&mut self, idx: Option<usize>) {
        let idx = idx.unwrap_or_else(|| self.selected);
        self.tasks[idx].state = TaskState::TODO;
    }

    fn goto(&mut self, idx: usize) {
        self.selected = idx;
    }

    fn agenda(&self) {
        for (idx, task) in self.tasks.iter().enumerate() {
            if task.day <= self.day && !matches!(task.state, TaskState::DONE) {
                println!("{}\t{}[{}]", task.day as i16 - self.day as i16, task.path, idx);
            }
        }
    }

    fn command(&mut self, args: Vec<&str>) {
        let cmd = &args[0];
        if cmd.parse::<usize>().is_ok() {
            self.goto(cmd.parse().unwrap_or_default());
        } else if *cmd == "ls" {
            if args.len() >= 2 {
                self.load_schedule(args[1]);
            }
        } else if *cmd == "ps" {
            self.print_schedule();
        } else if *cmd == "ss" {
            if args.len() >= 2 {
                self.save_schedule(args[1]);
            }
        } else if *cmd == "ft" {
            if args.len() >= 2 {
                self.find_task(args[1]);
            }
        } else if *cmd == "p" {
            self.print_selected_task();
        } else if *cmd == "do" {
            if args.len() >= 2 {
                self.done(Some(args[1].parse().unwrap_or_default()));
            } else {
                self.done(None)
            }
        } else if *cmd == "d" {
            if args.len() >= 2 {
                self.day = args[1].parse().unwrap_or_default();
            }
        } else if *cmd == "ag" {
            self.agenda();
        } else if *cmd == "td" {
            if args.len() >= 2 {
                self.todo(Some(args[1].parse().unwrap_or_default()));
            } else {
                self.todo(None)
            }
        }
    }
}

fn main() -> io::Result<()> {
    let input = io::stdin();
    let mut st = State::default();

    for arg in env::args().skip(1) {
        let f = match File::open(&arg) {
            Ok(f) => f,
            Err(_) => {
                panic!("Could not load file: {}", arg);
            }
        };

        let reader = BufReader::new(f);
        for line in reader.lines() {
            // TODO: error handling
            let line = line.unwrap();
            let args: Vec<_> = line.split_whitespace().collect();
            if args.is_empty() {
                continue;
            }
            if args[0] == "q" {
                break;
            }
            st.command(args);
        }
    }

    for line in input.lines() {
        // TODO: error handling
        let line = line.unwrap();
        let args: Vec<_> = line.split_whitespace().collect();
        if args.is_empty() {
            continue;
        }
        if args[0] == "q" {
            break;
        }
        st.command(args);
    }

    Ok(())
}
