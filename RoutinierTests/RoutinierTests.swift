//
//  RoutinierTests.swift
//  RoutinierTests
//

import CoreData
import Testing
@testable import Routinier

struct RoutinierTests {

    @Test func testRoutineModelMatchesCoreData() throws {
        let container = PersistenceController.preview.container
        let context = container.viewContext

        guard let entity = NSEntityDescription.entity(forEntityName: "Routine", in: context) else {
            #expect(Bool(false), "Routine entity not found in Core Data model.")
            return
        }

        let expectedAttributes: [String: NSAttributeType] = [
            "id": .UUIDAttributeType,
            "name": .stringAttributeType,
            "descriptionText": .stringAttributeType,
            "category": .stringAttributeType,
            "recurrenceType": .stringAttributeType,
            "recurrenceValue": .integer32AttributeType,
            "firstDueDate": .dateAttributeType,
            "nextDueDate": .dateAttributeType,
            "createdAt": .dateAttributeType
        ]

        for (name, type) in expectedAttributes {
            let attr = entity.attributesByName[name]
            #expect(attr != nil, "Missing attribute: \(name)")
            #expect(attr?.attributeType == type, "Attribute \(name) has wrong type")
        }

        let completions = entity.relationshipsByName["completions"]
        #expect(completions != nil, "Missing relationship: completions")
        #expect(completions?.isToMany == true, "completions should be to-many")
        #expect(completions?.destinationEntity?.name == "Completion", "completions should target Completion entity")
    }

    @Test func testCompletionModelMatchesCoreData() throws {
        let container = PersistenceController.preview.container
        let context = container.viewContext

        guard let entity = NSEntityDescription.entity(forEntityName: "Completion", in: context) else {
            #expect(Bool(false), "Completion entity not found in Core Data model.")
            return
        }

        let expectedAttributes: [String: NSAttributeType] = [
            "id": .UUIDAttributeType,
            "timestamp": .dateAttributeType
        ]

        for (name, type) in expectedAttributes {
            let attr = entity.attributesByName[name]
            #expect(attr != nil, "Missing attribute: \(name)")
            #expect(attr?.attributeType == type, "Attribute \(name) has wrong type")
        }

        let routine = entity.relationshipsByName["routine"]
        #expect(routine != nil, "Missing relationship: routine")
        #expect(routine?.isToMany == false, "routine should be to-one")
        #expect(routine?.destinationEntity?.name == "Routine", "routine should target Routine entity")
    }
}
