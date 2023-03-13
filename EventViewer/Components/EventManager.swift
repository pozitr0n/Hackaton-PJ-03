//
//  PersistentEventManager.swift
//  EventManager
//
//  Created by Ilya Kharlamov on 11/30/22.
//  Copyright © 2022 DIGITAL RETAIL TECHNOLOGIES, S.L. All rights reserved.
//

import CoreData
import Foundation

public final class EventManager: NSPersistentContainer {

    public let queue = DispatchQueue(label: "com.simla.PersistantEventManager", qos: .default)

    public var arrayOfStrings: Array<String> = []
    
    public init() {
        super.init(name: "PersistantEventManagerDB", managedObjectModel: Self.model)
        let description = NSPersistentStoreDescription()
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        persistentStoreDescriptions.append(description)
        loadPersistentStores(completionHandler: { _, error in
            if let error {
                fatalError(error.localizedDescription)
            } else {
                print("PersistantEventManager successfully loaded")
            }
        })
    }

    public func capture(_ event: Event) {
        performBackgroundTask({ context in
            let newRecord = DBEvent(context: context)
            newRecord.id = event.id
            newRecord.createdAt = Date()
            if !event.parameters.isEmpty {
                newRecord.parameters = Set(event.parameters.map({
                    DBParameter(parameter: $0, context: context)
                }))
            }
            do {
                try context.save()
                print("Event \"\(event.id)\" saved")
            } catch {
                print("Error:", error.localizedDescription)
            }
        })
    }

    public func entitiesCount() -> Int {
        do {
            return try viewContext.count(for: DBEvent.makeFetchRequest())
        } catch {
            print("Error:", error.localizedDescription)
            return .zero
        }
    }
    
    public func getAllTheEvents(countLimit: Int) -> Array<String> {
       
        do {
            
            let sectionSortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
            let sortDescriptors = [sectionSortDescriptor]
            
            let fetchRequest = DBEvent.makeFetchRequest()
            fetchRequest.sortDescriptors = sortDescriptors
            
            fetchRequest.fetchLimit = countLimit
            
            let finalInfo = try viewContext.fetch(fetchRequest)
            
            for currStr in finalInfo {
                if currStr.createdAt != nil {
                    
                    let currDateFromArray = currStr.createdAt!
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .medium
                    dateFormatter.timeStyle = .medium
                                
                    arrayOfStrings.append(dateFormatter.string(from: currDateFromArray) + " | " + currStr.id)
                    
                }
            }
        
        } catch let error as NSError {
            print("Can't fetch data from database because \(error)")
        }
        
        return arrayOfStrings
        
    }
    
    public func deleteEvent(currentIndex: Int) -> Bool {
        
        var objectDeleted: Bool = false
        
        let resultOfComponents: [String] = arrayOfStrings[currentIndex].components(separatedBy: ["|"])
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        
        let currentString = resultOfComponents.first!
        let finalDateToDelete = dateFormatter.date(from: currentString)
       
        do {
            
            let fetchRequest = DBEvent.makeFetchRequest()
            fetchRequest.predicate = NSPredicate(format: "createdAt = %@", finalDateToDelete! as CVarArg)
            
            let objects = try viewContext.fetch(fetchRequest)
            
            for object in objects {
                viewContext.delete(object)
                objectDeleted = true
            }
            
            try viewContext.save()
            
            if objectDeleted {
                arrayOfStrings.remove(at: currentIndex)
            }
            
        } catch let error as NSError {
            print("Can't fetch data from database because \(error)")
        }
        
        return objectDeleted
        
    }

    public func containsEvent(_ event: String, withParameters parameters: ParameterSet? = nil) -> Bool {
        containsEvent(with: preparePredicate(forEvent: event, withParameters: parameters))
    }

    public func containsEvent(with predicate: NSPredicate) -> Bool {
        let request = DBEvent.makeFetchRequest()
        request.predicate = predicate
        do {
            return try viewContext.count(for: request) > 0
        } catch {
            print("Error:", error.localizedDescription)
            return false
        }
    }

    public func lastDateOfEvent(_ event: String, withParameters parameters: ParameterSet? = nil) -> Date? {
        lastDateOfEvent(with: preparePredicate(forEvent: event, withParameters: parameters))
    }

    public func lastDateOfEvent(with predicate: NSPredicate) -> Date? {
        let request = DBEvent.makeFetchRequest()
        request.predicate = predicate
        let sort = NSSortDescriptor(key: #keyPath(DBEvent.createdAt), ascending: false)
        request.sortDescriptors = [sort]
        request.fetchLimit = 1
        do {
            return try viewContext.fetch(request).first?.createdAt
        } catch {
            print("Error:", error.localizedDescription)
            return nil
        }
    }

    public func clean(completion: ((Error?) -> Void)? = nil) {
        performBackgroundTask { context in
            do {
                let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: DBEvent.entityName)
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
                try context.execute(deleteRequest)
                if context.hasChanges {
                    try context.save()
                }
                DispatchQueue.main.async {
                    completion?(nil)
                }
            } catch {
                print("Error:", error.localizedDescription)
                DispatchQueue.main.async {
                    completion?(error)
                }
            }
        }
    }

    private func preparePredicate(forEvent event: String, withParameters parameters: ParameterSet?) -> NSPredicate {
        var subPredicates: [NSPredicate] = [
            NSPredicate(format: "id=%@", event)
        ]
        if let parameters {
            for (key, paramValue) in parameters {
                let value: (format: String, arg: CVarArg) = {
                    switch paramValue {
                    case .string(let value):
                        return ("stringValue = %@", value)
                    case .bool(let value):
                        return ("booleanValue = %@", value)
                    case .integer(let value):
                        return ("integerValue = %i", value)
                    case .array(let value):
                        return ("arrayValue = %@", value)
                    }
                }()
                let paramPredicate = NSPredicate(
                    format: "SUBQUERY(parameters, $p, $p.key = %@ AND $p.\(value.format)).@count > 0",
                    key,
                    value.arg
                )
                subPredicates.append(paramPredicate)
            }
        }
        return NSCompoundPredicate(andPredicateWithSubpredicates: subPredicates)
    }

}
