import Foundation

struct FeedDataProvider: FeedDataProviding {
    func articles() -> [ArticleType] {
        return []
    }
}

private struct Article: ArticleType {
    let title: String
    let image: URL?
    let sections: [SectionType]
}

private struct Section: SectionType {
    let title: String
    let bodyElements: [BodyElementType]
}
