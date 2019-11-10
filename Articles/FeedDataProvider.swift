import Foundation

struct FeedDataProvider: FeedDataProviding {
    func articles() -> [ArticleType] {
        var articles: [Article] = []
        
        let count = Int(arc4random_uniform(1000))
        for index in 0..<count {
            articles.append(Article(title: "TITLE: \(index)", image: URL(string: "https://via.placeholder.com/\(index)")!, sections: []))
        }
        
        return articles
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
