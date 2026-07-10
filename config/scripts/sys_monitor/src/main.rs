use sysinfo::{System, Disks};
use std::thread;
use std::time::Duration;

fn main() {
    let mut sys = System::new_all();

    loop {
        sys.refresh_cpu_usage();
        sys.refresh_memory();
        
        let cpu_usage: f32 = sys.cpus().iter().map(|cpu| cpu.cpu_usage()).sum::<f32>() / sys.cpus().len() as f32;

        let total_mem = sys.total_memory() as f64;
        let used_mem = sys.used_memory() as f64;
        let ram_usage = (used_mem / total_mem) * 100.0;

        let disks = Disks::new_with_refreshed_list();
        let mut disk_usage = 0.0;
        for disk in &disks {

            if disk.mount_point().to_str() == Some("/") {
                let total = disk.total_space() as f64;
                let available = disk.available_space() as f64;
                if total > 0.0 {
                    disk_usage = ((total - available) / total) * 100.0;
                }
                break;
            }
        }

        println!("{:.0}|{:.0}|{:.0}", cpu_usage, ram_usage, disk_usage);

        thread::sleep(Duration::from_secs(2));
    }
}