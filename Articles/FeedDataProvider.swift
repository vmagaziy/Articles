import Foundation

struct FeedDataProvider: FeedDataProviding {
    enum Error: Swift.Error {
        case unknown
    }
    
    func articles() -> Future<[ArticleType]> {
        var articles: [Article] = []
        
        let count = Int(arc4random_uniform(1000))
        for index in 0..<count {
            articles.append(Article(title: "TITLE: \(index)", image: URL(string: "https://via.placeholder.com/\(index)")!, publisher: "PUBLISHER: \(index)", sections: []))
        }
        
        let promise = Promise<[ArticleType]>()
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            if arc4random() % 2 == 0 {
                promise.resolve(with: articles)
            } else {
                promise.reject(with: Error.unknown)
            }
        }

        return promise
    }
}

private struct Article: ArticleType {
    let title: String
    let image: URL?
    let publisher: String?
    let sections: [SectionType]
}

private struct Section: SectionType {
    let title: String
    let bodyElements: [BodyElementType]
}
