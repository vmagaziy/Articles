import Foundation

struct FeedDataProvider: FeedDataProviding {
    private let httpClient: HTTPClient

    private static let endpointURL = URL(string: "https://raw.github.schibsted.io/gist/volodymyr-magazii/baaeb716d87d16218bd2dd9454fb5aa0/raw/e67bf40158ae22fce564a7e4a5b880c17a16c203/Payload.json?token=AAAM1614YuflnMbzsMF11cMFI4pGwF5fks5dzp3wwA%3D%3D")!

    init(httpClient: HTTPClient = HTTPClient()) {
        self.httpClient = httpClient
    }

    func articles() -> Future<[Article]> {
        return httpClient.load(url: FeedDataProvider.endpointURL).transformed { data in
            let payload = try JSONDecoder().decode(Payload.self, from: data)
            return payload.articles
        }
    }
}

private struct Payload: Decodable {
    let articles: [ArticleImpl]
}

private struct ArticleImpl: Decodable, Article {
    private enum CodingKeys: String, CodingKey {
        case title, image, publisher, sectionsImpl = "sections"
    }

    let title: String
    let image: URL?
    let publisher: String?
    let sectionsImpl: [SectionImpl]

    var sections: [Section] { sectionsImpl }
}

private struct SectionImpl: Decodable, Section {
    private enum CodingKeys: String, CodingKey {
        case title, bodyElements = "body_elements"
    }

    let title: String?
    let bodyElements: [BodyElement]
}

extension BodyElement: Decodable {
    private enum Keys: String, CodingKey {
        case imageURL = "image_url"
    }

    init(from decoder: Decoder) throws {
        if let text = try? decoder.singleValueContainer().decode(String.self) {
            self = .text(text)
        } else if let json = try? decoder.container(keyedBy: Keys.self) {
            let url = try json.decode(URL.self, forKey: .imageURL)
            self = .image(url)
        } else {
            throw BodyElement.decodingError(for: decoder)
        }
    }

    private static func decodingError(for decoder: Decoder) -> DecodingError {
        let description = """
        Expected a String or a Dictionary containing a
        '\(Keys.imageURL.stringValue)' key with value.
        """
        return .typeMismatch(self, .init(codingPath: decoder.codingPath, debugDescription: description))
    }
}
