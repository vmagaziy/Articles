class Future<Value> {
    fileprivate var result: Result<Value, Error>? {
        didSet { result.map(report) }
    }
    
    private lazy var callbacks = [(Result<Value, Error>) -> Void]()

    func observe(_ callback: @escaping (Result<Value, Error>) -> Void) {
        callbacks.append(callback)
        result.map(callback)
    }

    private func report(result: Result<Value, Error>) {
        callbacks.forEach { $0(result) }
    }
}

final class Promise<Value>: Future<Value> {
    init(value: Value? = nil) {
        super.init()
        result = value.map(Result.success)
    }

    func resolve(with value: Value) {
        result = .success(value)
    }

    func reject(with error: Error) {
        result = .failure(error)
    }
}
