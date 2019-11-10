import Foundation

protocol FeedDataProviding {
    func articles() -> Future<[ArticleType]>
}

protocol ArticleType {
    var title: String { get }
    var image: URL? { get }
    var publisher: String? { get }
    var sections: [SectionType] { get }
}

protocol SectionType {
    var title: String { get }
    var bodyElements: [BodyElementType] { get }
}

enum BodyElementType {
    case text(String)
    case image(URL)
}
