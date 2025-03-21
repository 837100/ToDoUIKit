//
//  TodoTableViewController.swift
//  ToDoUIKit
//
//  Created by NO SEONGGYEONG on 3/20/25.
//

import CoreData
import UIKit

class TodoTableViewController: UITableViewController {
    
    // MARK: - Properties
    private var items: [TodoItem] = []
    
    // 카테고리 별로
    private var categorizedItems: [String: [TodoItem]] = [:]
    private var categories: [String] = []
    
    private var persistentContainer =
    (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    
    private var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigation()
        configureTableView()
        loadTodoItems()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTodoItem)
        )
        
        let longPressGesture = UILongPressGestureRecognizer(
            target: self,
            action: #selector(handleLongPress))
        tableView.addGestureRecognizer(longPressGesture)
        
    }
    
    @objc private func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                // 선택된 할 일 가져오기
                let category = categories[indexPath.section]
                let selectedItem = categorizedItems[category]![indexPath.row]
                // 수정 화면 표시
                editTodoItem(selectedItem)
            }
        }
    }
    
    private func editTodoItem(_ item: TodoItem) {
        let addVC = TodoAddViewController()
        addVC.editMode = true
        addVC.todoItemToEdit = item
        let navigationController = UINavigationController(rootViewController: addVC)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTodoItems()
    }
    
    func configureNavigation() {
        title = "할 일"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func configureTableView() {
        tableView.register(
            UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        tableView.rowHeight = 60
    }
    
    @objc private func addTodoItem() {
        let addVC = TodoAddViewController()
        let navigationController = UINavigationController(
            rootViewController: addVC)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
    
    private func organizeCategorizedItems() {
        categorizedItems.removeAll()
        categories.removeAll()
        
        for item in items {
            let category = item.category
            
            if categorizedItems[category] == nil {
                categorizedItems[category] = []
                categories.append(category)
            }
            
            categorizedItems[category]?.append(item)
            
        }
        categories.sort()
    }
    
    private func loadTodoItems() {
        let request: NSFetchRequest<TodoItemEntity> =
        TodoItemEntity.fetchRequest()
        // 생성일 순으로 정렬
        request.sortDescriptors = [
            NSSortDescriptor(key: "createdAt", ascending: true)
        ]
        
        do {
            let result = try viewContext.fetch(request)
            items = result.compactMap { TodoItem.from($0) }
            organizeCategorizedItems()
            tableView.reloadData()
        } catch {
            print("데이터를 불러오는데 실패했습니다.")
        }
    }
    
    private func saveTodoItem(_ item: TodoItem) {
        let _ = item.toManagedObject(in: viewContext)
        
        do {
            try viewContext.save()
            loadTodoItems()
        } catch {
            print("저장 실패 \(error)")
        }
    }
    
    
    private func deleteTodoItem(_ item: TodoItem) {
        let request: NSFetchRequest<TodoItemEntity> =
        TodoItemEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", item.id as CVarArg)
        
        do {
            let result = try viewContext.fetch(request)
            guard let object = result.first else { return }
            
            viewContext.delete(object)
            try viewContext.save()
            
            loadTodoItems()
        } catch {
            print("삭제 실패: \(error)")
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return categories[section]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let category = categories[section]
        return categorizedItems[category]?.count ?? 0
    }
    
    override func tableView(
        _ tableView: UITableView, cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "reuseIdentifier", for: indexPath)
        let category = categories[indexPath.section]
        let item = categorizedItems[category]![indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.image = UIImage(
            systemName: item.isDone ? "checkmark.circle.fill" : "circle")
        
        content.text = item.todo
        content.secondaryText = item.setTime.description
        
        content.imageProperties.maximumSize = CGSize(width: 30, height: 20)
        
        content.imageProperties.tintColor =
        item.isDone ? .systemGreen : .systemGray
        
        cell.contentConfiguration = content
        // 오른쪽에 중요도 표시를 위한 레이블 추가
        let priorityLabel = UILabel()
        priorityLabel.text = item.priority
        priorityLabel.textColor = .systemGray
        priorityLabel.sizeToFit()
        cell.accessoryView = priorityLabel
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let category = categories[indexPath.section]
            let item = categorizedItems[category]![indexPath.row]
            deleteTodoItem(item)
        }
    }
    
    override func tableView(
        _ tableView: UITableView, didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        let category = categories[indexPath.section]
        let selectedItem = categorizedItems[category]![indexPath.row]
        toggleItemCompletion(selectedItem)
    }
    
    private func toggleItemCompletion(_ item: TodoItem) {
        let request: NSFetchRequest<TodoItemEntity> =
        TodoItemEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", item.id as CVarArg)
        
        do {
            // 요청 실행하여 결과 가져오기
            let results = try viewContext.fetch(request)
            
            // 해당 학목이 존재하는지 확인
            if let todoEntity = results.first {
                // 토글
                todoEntity.isDone = !todoEntity.isDone
                
                try viewContext.save()
                
                loadTodoItems()
                
                print("할 일 상태 업데이트 성공: \(item.todo) - 완료: \(todoEntity.isDone)")
            } else {
                print("할 일을 찾을 수 없습니다.: \(item.id) - \(item.todo)")
            }
        } catch {
            print("완료 상태 변경 실패: \(error)")
        }
    }
    
}
#Preview {
    UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!
}
