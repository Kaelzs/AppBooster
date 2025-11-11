//
//  Combine.swift
//  AppBooster
//
//  Created by Kael on 10/13/25.
//

import Combine

private enum Either<Left, Right> {
    case left(Left)
    case right(Right)
}

public extension Publisher {
    func withLatestFrom<Other: Publisher>(_ other: Other) -> some Publisher<(Output, Other.Output), Failure> where Other.Failure == Failure {
        typealias EitherType = Either<Output, Other.Output>
        typealias ScanType = (left: Output?, right: Other.Output?, emit: Bool)

        return map(EitherType.left)
            .merge(with: other.map(EitherType.right))
            .scan((nil, nil, false) as ScanType) { output, either in
                var output = output
                switch either {
                case .left(let value):
                    output.left = value
                    output.emit = true
                case .right(let value):
                    output.right = value
                    output.emit = false
                }
                return output
            }
            .compactMap { scanResult in
                if scanResult.emit,
                   let left = scanResult.left,
                   let right = scanResult.right {
                    return (left, right)
                }
                return nil
            }
    }
}

public extension Array where Element: Publisher {
    func combineLatest() -> AnyPublisher<[Element.Output], Element.Failure> {
        Publishers.CombineLatestArray(self)
    }
}

public extension Publishers {
    static func CombineLatestArray<P>(_ array: [P]) -> AnyPublisher<[P.Output], P.Failure> where P: Publisher {
        if array.isEmpty {
            return Just([]).setFailureType(to: P.Failure.self).eraseToAnyPublisher()
        } else if array.count == 1 {
            return array[0].map { [$0] }.eraseToAnyPublisher()
        } else {
            return array.dropFirst().reduce(into: AnyPublisher(array[0].map { [$0] })) { res, ob in
                res = res.combineLatest(ob) { i1, i2 -> [P.Output] in
                    return i1 + [i2]
                }.eraseToAnyPublisher()
            }
        }
    }
}
