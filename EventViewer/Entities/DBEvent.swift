//
//  DBEvent.swift
//  EventManager
//
//  Created by Ilya Kharlamov on 11/30/22.
//  Copyright © 2022 DIGITAL RETAIL TECHNOLOGIES, S.L. All rights reserved.
//

import CoreData

internal final class DBEvent: NSManagedObject {

    internal final class var entityName: String {
        "Event"
    }

    internal final class func entity(in managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        NSEntityDescription.entity(forEntityName: self.entityName, in: managedObjectContext)
    }

    @nonobjc
    internal final class func makeFetchRequest() -> NSFetchRequest<DBEvent> {
        NSFetchRequest<DBEvent>(entityName: self.entityName)
    }

    @NSManaged internal var id: String
    @NSManaged internal var createdAt: Date?
    @NSManaged internal var parameters: Set<DBParameter>?

}

// MARK: Relationship Parameters

extension DBEvent {
    @objc(addUploadTasksObject:)
    @NSManaged
    public func addToParameters(_ value: DBParameter)

    @objc(removeUploadTasksObject:)
    @NSManaged
    public func removeFromParameters(_ value: DBParameter)

    @objc(addUploadTasks:)
    @NSManaged
    public func addToParameters(_ values: Set<DBParameter>)

    @objc(removeUploadTasks:)
    @NSManaged
    public func removeFromParameters(_ values: Set<DBParameter>)
}
