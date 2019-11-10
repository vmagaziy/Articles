import Foundation

struct FeedDataProvider: FeedDataProviding {
    func articles() -> Future<[ArticleType]> {
        var articles: [Article] = []
        
        let count = Int(arc4random_uniform(1000))
        for index in 0..<count {
            articles.append(Article(title: "TITLE: \(index)", image: URL(string: "https://via.placeholder.com/\(index)")!, sections: []))
        }
        
        let promise = Promise<[ArticleType]>()
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            promise.resolve(with: articles)
        }

        return promise
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
