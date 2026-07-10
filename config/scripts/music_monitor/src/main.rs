use mpris::{PlayerFinder, PlaybackStatus};
use std::thread;
use std::time::Duration;
use std::io::Write;


fn main() {
    println!("Hello, world!");

    let player_finder = PlayerFinder::new()
                    .expect("Can not connect");

    loop {
        if let Ok(player) = player_finder.find_active() {
            let status = player.get_playback_status().unwrap_or(PlaybackStatus::Stopped);
            let status_str = match status {
                PlaybackStatus::Playing => "Playing",
                PlaybackStatus::Paused => "Paused",
                PlaybackStatus::Stopped => "Stopped",
            };

            let metadata = player.get_metadata().unwrap_or_default();
            let title = metadata.title().unwrap_or("");
            let artist = metadata.artists().map(|a| a.join(", ")).unwrap_or_default();
            
            let length = metadata.length().unwrap_or(Duration::from_secs(0)).as_secs_f64();

            let position = player.get_position().unwrap_or(Duration::from_secs(0)).as_secs_f64();

            println!("{}|{}|{}|{}|{}", status_str, title, artist, position, length);

        } else {
            // Если плеер закрыт или ничего не играет
            println!("Stopped|||0|0");
        }
        std::io::stdout().flush().unwrap();
        thread::sleep(Duration::from_millis(500));


        }
    }


