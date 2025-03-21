//
//  TodoItem.swift
//  ToDoUIKit
//
//  Created by NO SEONGGYEONG on 3/20/25.
//

import UIKit
import CoreData

struct TodoItem: Hashable {
    let id: UUID
    var todo: String
    var isDone: Bool
    var setTime: Date
    var category: String
    var priority: String
    var createdAt: Date
        
    init(id: UUID, todo: String, isDone: Bool, setTime: Date, category: String, priority: String, createdAt: Date) {
        self.id = id
        self.todo = todo
        self.isDone = isDone
        self.setTime = setTime
        self.category = category
        self.priority = priority
        self.createdAt = createdAt
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: TodoItem, rhs: TodoItem) -> Bool {
        return lhs.id == rhs.id
    }
}

extension TodoItem {
    // TodoItem -> TodoItemEntity 변환
    func toManagedObject(in context: NSManagedObjectContext) -> TodoItemEntity {
        let entity = TodoItemEntity(context: context)
        entity.id = id
        entity.todo = todo
        entity.isDone = isDone
        entity.setTime = setTime
        entity.category = category
        entity.priority = priority
        entity.createdAt = createdAt
        return entity
    }
    
    // TodoItemEntity -> TodoItem 변환
    static func from(_ entity: TodoItemEntity) -> TodoItem? {
        guard let id = entity.id,
              let todo = entity.todo,
              let setTime = entity.setTime,
              let category = entity.category,
              let priority = entity.priority else {
            return nil
        }
        
        var item = TodoItem(
            id: id,
            todo: todo,
            isDone: entity.isDone,
            setTime: setTime,
            category: category,
            priority: priority,
            createdAt: entity.createdAt ?? Date())
        return item
    }
}
