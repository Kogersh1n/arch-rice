use reqwest::Client;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

#[derive(Deserialize)]
struct MangaDexResponse {
    data: Vec<MangaItem>
}

#[derive(Deserialize)]
struct MangaItem {
    id: String,
    attributes:MangaAttributes,
    relationships: Vec<Relationship>
}

#[derive(Deserialize)]
struct MangaAttributes {
    title: HashMap<String, String>,
}

#[derive(Deserialize)]
struct Relationship {
    #[serde(rename = "type")] 
    rel_type: String,
    attributes: Option<RelationshipAttributes>,
}

#[derive(Deserialize)]
struct RelationshipAttributes {
    // В JSON оно fileName (camelCase), а в Rust принято file_name (snake_case)
    #[serde(rename = "fileName")]
    file_name: Option<String>,
}


#[derive(Serialize)]
struct QmlManga {
    id: String,
    title: String,
    coverUrl: String,
}





#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {    
    
    let api_url = "https://api.mangadex.org/manga?limit=15&order[followedCount]=desc&includes[]=cover_art";

    let client = Client::new();

    let response = client.get(api_url).send().await?.json::<MangaDexResponse>().await?;

    let mut qml_list = Vec::new();

    for manga in response.data {

        let title = manga.attributes.title.get("en")
            .or_else(|| manga.attributes.title.values().next())
            .cloned()
            .unwrap_or_else(|| "Unknown".to_string());


        let mut cover_url = String::new();
        for rel in manga.relationships {
            if rel.rel_type == "cover_art"{

                if let Some(attrs) = rel.attributes {
                    if let Some(file_name) = attrs.file_name {
                        cover_url = format!("https://uploads.mangadex.org/covers/{}/{}.256.jpg", manga.id, file_name);
                    }
                }
            }
            
        }

        if !cover_url.is_empty() {
            qml_list.push(QmlManga {
                id: manga.id,
                title,
                coverUrl: cover_url,
            });
        }

    }

    let json_output = serde_json::to_string(&qml_list)?;
    println!("{}", json_output);

    Ok(())


}

