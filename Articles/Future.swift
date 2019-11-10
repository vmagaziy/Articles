import Dispatch

class Future<Value> {
    fileprivate var result: Result<Value, Error>? {
        didSet { result.map(report) }
    }
    
    typealias Callback = (Result<Value, Error>) -> Void
    private lazy var callbacks = [(Callback, DispatchQueue)]()

    func observe(on queue: DispatchQueue = .main, _ callback: @escaping Callback) {
        callbacks.append((callback, queue))
        result.map(callback)
    }

    private func report(result: Result<Value, Error>) {
        callbacks.forEach {
            let (callback, queue) = $0
            queue.async { callback(result) }
        }
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
