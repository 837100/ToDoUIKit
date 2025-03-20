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
    var priority: Int
    var createdAt: Date
        
    init(id: UUID, todo: String, isDone: Bool, setTime: Date, category: String, priority: Int, createdAt: Date) {
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
