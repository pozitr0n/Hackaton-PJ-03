//
//  DBParamenter.swift
//  EventManager
//
//  Created by Ilya Kharlamov on 12/2/22.
//  Copyright © 2022 DIGITAL RETAIL TECHNOLOGIES, S.L. All rights reserved.
//

import CoreData

internal final class DBParameter: NSManagedObject {

    internal final class var entityName: String {
        "Parameter"
    }

    internal final class func entity(in managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        NSEntityDescription.entity(forEntityName: self.entityName, in: managedObjectContext)
    }

    @nonobjc
    internal final class func makeFetchRequest() -> NSFetchRequest<DBParameter> {
        NSFetchRequest<DBParameter>(entityName: self.entityName)
    }

    @NSManaged internal var key: String
    @NSManaged internal var stringValue: String?
    @NSManaged internal var arrayValue: Set<DBParameter>?
    @NSManaged internal var event: DBEvent?

    internal var integerValue: Int32? {
        get {
            let key = "integerValue"
            willAccessValue(forKey: key)
            defer { didAccessValue(forKey: key) }
            return primitiveValue(forKey: key) as? Int32
        }
        set {
            let key = "integerValue"
            willChangeValue(forKey: key)
            defer { didChangeValue(forKey: key) }
            setPrimitiveValue(newValue, forKey: key)
        }
    }

    internal var booleanValue: Bool? {
        get {
            let key = "booleanValue"
            willAccessValue(forKey: key)
            defer { didAccessValue(forKey: key) }
            return primitiveValue(forKey: key) as? Bool
        }
        set {
            let key = "booleanValue"
            willChangeValue(forKey: key)
            defer { didChangeValue(forKey: key) }
            setPrimitiveValue(newValue, forKey: key)
        }
    }

}

extension DBParameter {

    convenience init(parameter: (ParameterSet.Key, ParameterSet.Value), context: NSManagedObjectContext) {
        self.init(context: context)
        let (key, value) = parameter
        self.key = key
        switch value {
        case .bool(let value):
            self.booleanValue = value
        case .string(let value):
            self.stringValue = value
        case .integer(let value):
            self.integerValue = Int32(value)
        case .array(let value):
            self.arrayValue = Set(value.map({ DBParameter(parameter: (key, $0), context: context) }))
        }
    }

}
