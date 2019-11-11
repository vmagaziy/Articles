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

extension Future {
    func chained<NextValue>(with closure: @escaping (Value) throws -> Future<NextValue>) -> Future<NextValue> {
        let promise = Promise<NextValue>()
        let queue = DispatchQueue.global()
        observe(on: queue) {
            switch $0 {
            case .success(let value):
                do {
                    let nested = try closure(value)
                    nested.observe(on: queue) { result in
                        switch result {
                        case .success(let value):
                            promise.resolve(with: value)
                        case .failure(let error):
                            promise.reject(with: error)
                        }
                    }
                } catch {
                    promise.reject(with: error)
                }
            case .failure(let error):
                promise.reject(with: error)
            }
        }

        return promise
    }

    func transformed<NextValue>(with closure: @escaping (Value) throws -> NextValue) -> Future<NextValue> {
        return chained { try Promise(value: closure($0)) }
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
