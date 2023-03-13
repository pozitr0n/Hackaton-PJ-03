//
//  ParameterSet.swift
//  EventViewer
//
//  Created by Ilya Kharlamov on 1/26/23.
//

import Foundation

public struct ParameterSet: CustomStringConvertible, Collection {

    public typealias DictionaryType = [String: Value]

    // Collection: these are the access methods
    public typealias Indices = DictionaryType.Indices
    public typealias Iterator = DictionaryType.Iterator
    public typealias SubSequence = DictionaryType.SubSequence
    public typealias Index = DictionaryType.Index

    private var data: DictionaryType
    public var startIndex: Index { self.data.startIndex }
    public var endIndex: DictionaryType.Index { self.data.endIndex }
    public var indices: Indices { self.data.indices }
    public var keys: DictionaryType.Keys { self.data.keys }

    public var description: String {
        "\(self.data.mapValues(\.asAny))"
    }

    public init() {
        self.data = [:]
    }

    public func index(after i: Index) -> Index {
        data.index(after: i)
    }

    public func makeIterator() -> DictionaryIterator<Key, Value> {
        data.makeIterator()
    }

    public subscript(index: Key) -> Value? {
        get { data[index] }
        set { data[index] = newValue }
    }

    public subscript(position: Index) -> Iterator.Element {
        data[position]
    }

    public subscript(bounds: Range<Index>) -> SubSequence {
        data[bounds]
    }

    public var asAny: [String: Any] {
        data.reduce(into: [String: Any](), { $0[$1.key] = $1.value.asAny })
    }

    public func mapValues<T>(_ transform: (Value) throws -> T) rethrows -> [Key: T] {
        try data.mapValues(transform)
    }

}

extension ParameterSet: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, Value)...) {
        self.data = elements.reduce(into: [String: Value](), { $0[$1.0] = $1.1 })
    }
}

public extension ParameterSet {
    enum Value: Hashable {
        case bool(Bool)
        case string(String)
        case integer(Int)
        case array([Value])
    }
}

extension ParameterSet.Value: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: ParameterSet.Value...) {
        self = .array(elements)
    }
}

public extension ParameterSet.Value {
    static func raw<RawObject: RawRepresentable>(_ raw: RawObject) -> ParameterSet.Value where RawObject.RawValue == String {
        .string(raw.rawValue)
    }

    static func raw<RawObject: RawRepresentable>(_ raw: RawObject) -> ParameterSet.Value where RawObject.RawValue == Int {
        .integer(raw.rawValue)
    }

    static func raw<RawObject: RawRepresentable>(_ raw: RawObject) -> ParameterSet.Value where RawObject.RawValue == Bool {
        .bool(raw.rawValue)
    }
}

extension ParameterSet.Value: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        self = .integer(value)
    }
}

extension ParameterSet.Value: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .bool(value)
    }
}

extension ParameterSet.Value: ExpressibleByStringInterpolation {
    public init(stringInterpolation: DefaultStringInterpolation) {
        self = .string(stringInterpolation.description)
    }

    public init(stringLiteral value: StringLiteralType) {
        self = .string(value)
    }
}

public extension ParameterSet.Value {

    var asInt: Int? {
        if case .integer(let value) = self {
            return value
        }
        return nil
    }

    var asBool: Bool? {
        if case .bool(let value) = self {
            return value
        }
        return nil
    }

    var asAny: Any {
        switch self {
        case .bool(let value):
            return value
        case .string(let value):
            return value
        case .integer(let value):
            return value
        case .array(let value):
            return value.map(\.asAny)
        }
    }

    var asString: String {
        switch self {
        case .bool(let bool):
            return bool ? "true" : "false"
        case .string(let string):
            return string
        case .integer(let int):
            return "\(int)"
        case .array(let value):
            return value.map(\.asString).joined(separator: ", ")
        }
    }

}
