import UIKit


// Printing JSON DATA
extension Data{
    func prettyPrintedJSONString(){
        guard let jsonObject = try? JSONSerialization.jsonObject(with: self, options:[]),
              let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
              let prettyJSONString = String(data: jsonData,encoding: .utf8)else{
                print("Failed to read JSON Object")
            return
        }
        print(prettyJSONString);
    }
}

//var URLComponent = URLComponents(string:"https://itunes.apple.com/search")!
//
//URLComponent.queryItems=[
//    "term": "Apple",
//    "media": "ebook",
//    "attribute": "authorTerm",
//    "lang": "en_us",
//    "limit": "10"
//].map{URLQueryItem(name: $0.key, value: $0.value)}
//
//
//
//Task{
//    let(data,response) = try await URLSession.shared.data(from: URLComponent.url!)
//    
//    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200{
//        //print(data)
//        data.prettyPrintedJSONString()
////        if let string = String(data:data, encoding: .utf8){
////            print(string)
////        }
//    }
//    else{
//        // error handling
//    }
//}

//Model
struct StoreItem : Codable{
    let name: String
    let artist: String
    var kind: String
    var description: String
    var artworkURL: String
    
    enum CodingKeys: String, CodingKey{
        case name = "trackName"
        case artist = "artistName"
        case kind
        case description
//        case description = "longDescription"
        case artworkURL = "artworkUrl100"
    }
    
    enum AdditionalKeys : String, CodingKey{
        case longDescription
    }
    
    init(from decoder: Decoder)throws{
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self,forKey: CodingKeys.name)
        artist = try values.decode(String.self, forKey: CodingKeys.artist)
        kind = try values.decode(String.self,forKey: CodingKeys.kind)
        artworkURL = try values.decode(String.self, forKey: CodingKeys.artworkURL)
        description = try values.decode(String.self, forKey: CodingKeys.description)
//        if let description = try? values.decode(String.self, forKey: CodingKeys.description) {
//            self.description = description
//        } else {
//            let additionalValues = try decoder.container(keyedBy: AdditionalKeys.self)
//            description = (try? additionalValues.decode(String.self, forKey: AdditionalKeys.longDescription)) ?? ""
//        }
    }
}

// Responses
struct SearchResponse: Codable {
    let results: [StoreItem]
}

//Error
enum StoreItemError: Error, LocalizedError {
    case itemsNotFound
}

// Function to Fetch Items

func fetchItems(matching query: [String: String]) async throws -> [StoreItem] {
    var urlComponents = URLComponents(string: "https://itunes.apple.com/search")!
    urlComponents.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
    
    let (data, response) = try await URLSession.shared.data(from: urlComponents.url!)
    
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
        throw StoreItemError.itemsNotFound
    }
    
    let decoder = JSONDecoder()
    let searchResponse = try decoder.decode(SearchResponse.self, from: data)

    return searchResponse.results
}

let query = [
    "term": "Apple",
    "media": "ebook",
    "attribute": "authorTerm",
    "lang": "en_us",
    "limit": "10"
]

Task {
    do {
        let storeItems = try await fetchItems(matching: query)
        storeItems.forEach { item in
            print("""
            Name: \(item.name)
            Artist: \(item.artist)
            Kind: \(item.kind)
            Description: \(item.description)
            Artwork URL: \(item.artworkURL)


            """)
        }
    } catch {
        print(error)
    }
}
