use std::collections::BTreeMap;
use std::env;
use std::fs::File;
use std::io;
use std::io::prelude::*;
use std::io::BufReader;

#[derive(Clone)]
enum TaskState {
    TODO,
    DONE,
    DELETED,
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
            TaskState::DELETED => return "DELETED".to_string(),
        }
    }
}

impl From<&str> for TaskState {
    fn from(s: &str) -> TaskState {
        if s == "TODO" {
            return TaskState::TODO;
        } else if s == "DONE" {
            return TaskState::DONE;
        } else if s == "DELETED" {
            return TaskState::DELETED;
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
    group: u64,
}

impl Task {
    pub fn active(&self, group: u64) -> bool {
        if matches!(self.state, TaskState::DELETED) {
            return false;
        }
        group == 0 || (self.group & group) > 0
    }
}

#[allow(dead_code)]
#[derive(Default)]
struct State {
    tasks: Vec<Task>,
    schedule: BTreeMap<usize, Vec<usize>>,
    selected: usize,
    day: usize,
    group: u64,
    statefile: Option<String>,
}

impl State {
    fn import_schedule(&mut self, filename: &str) {
        let f = match File::open(filename) {
            Ok(f) => f,
            Err(_) => {
                println!("Could not load file.");
                return;
            }
        };

        let reader = BufReader::new(f);

        for line in reader.lines() {
            match line {
                Ok(line) => self.parse_and_append_entry(&line),
                Err(_) => continue,
            };
        }
    }

    fn parse_and_append_entry(&mut self, line: &str)
    {
        let task = self.parse_entry(line);
        self.tasks.push(task);
    }

    fn parse_entry(&self, line: &str) -> Task {
        let fields: Vec<_> = line.split(":").collect();
        let path = fields[0].to_string();
        let state = if fields.len() >= 3 {
            fields[2].into()
        } else {
            TaskState::default()
        };

        let day = if fields.len() >= 2 {
            fields[1].parse().unwrap_or_default()
        } else {
            0
        };

        let group = if fields.len() >= 4 {
            fields[3].parse().unwrap_or_default()
        } else {
            self.group
        };

        Task {
            path,
            day,
            state,
            group,
        }
    }

    fn load_schedule(&mut self, filename: Option<&str>) {
        let filename = if let Some(filename) = filename {
            filename
        } else if let Some(statefile) = &self.statefile {
            statefile
        } else {
            return;
        };

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
                Ok(line) => self.parse_and_append_entry(&line),
                Err(_) => continue,
            };
        }
    }

    fn print_schedule(&self) {
        for (idx, task) in self.tasks.iter().enumerate() {
            if !task.active(self.group) {
                continue;
            }
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
            if matches!(task.state, TaskState::DELETED) { continue };
            let state: String = (&task.state).into();
            let _ = write!(
                buffer,
                "{}:{}:{}:{}\n",
                task.path, task.day, state, task.group
            );
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
            if task.active(self.group)
                && task.day <= self.day
                && !matches!(task.state, TaskState::DONE)
            {
                println!(
                    "{}\t{}[{}]",
                    task.day as i16 - self.day as i16,
                    task.path,
                    idx
                );
            }
        }
    }

    fn command(&mut self, args: Vec<&str>) {
        let cmd = &args[0];
        if cmd.parse::<usize>().is_ok() {
            self.goto(cmd.parse().unwrap_or_default());
        } else if *cmd == "ls" {
            if args.len() >= 2 {
                self.load_schedule(Some(args[1]));
            } else {
                self.load_schedule(None);
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
        } else if *cmd == "gr" {
            self.group = 0;
            for i in 1..args.len() {
                let g: u8 = args[i].parse().unwrap_or_default();
                self.group |= 1 << g;
            }
        } else if *cmd == "ds" {
            if args.len() >= 2 {
                let ndays = args[1].parse().unwrap_or_else(|_| 1);
                self.distribute(ndays);
            }
        } else if *cmd == "is" {
            if args.len() >= 2 {
                self.import_schedule(args[1]);
            }
        } else if *cmd == "f" {
            if args.len() >= 2 {
                self.statefile = Some(args[1].to_string());
            }
        } else if *cmd == "w" {
            if let Some(statefile) = &self.statefile {
                self.save_schedule(statefile);
            }
        } else if *cmd == "up" {
            if args.len() >= 2 {
                self.update(args[1]);
            }
        }
    }

    pub fn distribute(&mut self, ndays: u16) {
        let mut ntasks = 0;

        for task in &self.tasks {
            if task.active(self.group) {
                ntasks += 1;
            }
        }

        let spread = ndays as f32 / ntasks as f32;

        let mut n = 0;

        for task in &mut self.tasks {
            if task.active(self.group) {
                task.day = (n as f32 * spread) as usize;
                n += 1;
            }
        }
    }

    fn find_existing_task(&self, path: &str) -> (usize, Option<&Task>) {
        for (id, task) in self.tasks.iter().enumerate() {
            if task.path == path {
                return (id, Some(task))
            }
        }
        (0, None)
    }

    pub fn mark_deleted(&mut self, id: usize) {
        self.tasks[id].state = TaskState::DELETED;
    }

    pub fn append_task(&mut self, task: Task) {
        self.tasks.push(task);
    }

    pub fn update(&mut self, filename: &str) {
        let f = match File::open(filename) {
            Ok(f) => f,
            Err(_) => {
                println!("Could not load file.");
                return;
            }
        };

        let reader = BufReader::new(f);

        for line in reader.lines() {
            let mut task = match line {
                Ok(line) => self.parse_entry(&line),
                Err(_) => continue,
            };

            let (id, existing) = self.find_existing_task(&task.path);

            if let Some(existing) = existing {
                // existing task clobbers any imported data
                task.day = existing.day;
                task.state = existing.state.clone();
                task.group = existing.group;
            }

            self.mark_deleted(id);
            self.append_task(task);
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
