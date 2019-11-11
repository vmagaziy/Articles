import Foundation

protocol FeedDataProviding {
    func articles() -> Future<[Article]>
}

protocol Article {
    var title: String { get }
    var image: URL? { get }
    var publisher: String? { get }
    var sections: [Section] { get }
}

protocol Section {
    var title: String? { get }
    var bodyElements: [BodyElement] { get }
}

enum BodyElement {
    case text(String)
    case image(URL)
}
