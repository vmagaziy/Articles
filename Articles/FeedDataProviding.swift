import Foundation

protocol FeedDataProviding {
    func articles() -> [ArticleType] // TODO: MAKE ASYNC
}

protocol ArticleType {
    var title: String { get }
    var image: URL? { get }
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
