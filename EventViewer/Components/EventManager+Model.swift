//
//  PersistantEventManager+Model.swift
//  EventManager
//
//  Created by Ilya Kharlamov on 11/30/22.
//  Copyright © 2022 DIGITAL RETAIL TECHNOLOGIES, S.L. All rights reserved.
//

import CoreData

extension EventManager {

    static let model: NSManagedObjectModel = {

        let event = NSEntityDescription(class: DBEvent.self)
        let parameter = NSEntityDescription(class: DBParameter.self)

        event.properties = [
            NSAttributeDescription(name: "id", type: .stringAttributeType),
            NSAttributeDescription(name: "createdAt", type: .dateAttributeType, isOptional: false),
            NSRelationshipDescription(name: "parameters", type: .oneToMany, destinationEntity: parameter, isOptional: true)
        ]

        parameter.properties = [
            NSAttributeDescription(name: "key", type: .stringAttributeType),
            NSRelationshipDescription(name: "event", type: .oneToOne, destinationEntity: event, isOptional: true),
            NSAttributeDescription(name: "stringValue", type: .stringAttributeType, isOptional: true),
            NSAttributeDescription(name: "integerValue", type: .integer32AttributeType, isOptional: true),
            NSAttributeDescription(name: "booleanValue", type: .booleanAttributeType, isOptional: true),
            NSRelationshipDescription(name: "arrayValue", type: .oneToMany, destinationEntity: parameter, isOptional: false)
        ]

        let model = NSManagedObjectModel()
        model.entities = [event, parameter]

        // Make inverse relationships
        model.entities.forEach { entity in
            entity.properties.forEach { relationship in
                guard let relationship = relationship as? NSRelationshipDescription else { return }
                let destionationEntity = relationship.destinationEntity
                if let inverseRelationship = destionationEntity?.relationships(forDestination: entity).first {
                    relationship.inverseRelationship = inverseRelationship
                }
            }
        }

        return model
    }()

}
