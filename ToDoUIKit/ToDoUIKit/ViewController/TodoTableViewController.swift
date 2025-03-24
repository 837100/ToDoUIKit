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
        configureSearchController()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTodoItem)
        )
        
    }
    
    func configureTableView() {
        
        tableView = UITableView(frame: view.bounds, style: .insetGrouped)
        // 커스텀 셀 등록
        tableView.register(
            TodoTableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        tableView.rowHeight = 60
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
//        navigationController?.navigationBar.prefersLargeTitles = true
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
        guard let cell = tableView.dequeueReusableCell(
            //        withIdentifier: TodoTableViewCell.reuseIdentifier, for: indexPath) as? TodoTableViewCell else {
            withIdentifier: "reuseIdentifier", for: indexPath) as? TodoTableViewCell else {
            return UITableViewCell()
        }
        let category = categories[indexPath.section]
        let item = categorizedItems[category]![indexPath.row]
        
        cell.configure(with: item)
        cell.delegate = self
        
        return cell
    }
    
    // 삭제 기능 구현
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let category = categories[indexPath.section]
            let item = categorizedItems[category]![indexPath.row]
            deleteTodoItem(item)
        }
    }
    
    // 완료 상태 변경
    override func tableView(
        _ tableView: UITableView, didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
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

extension TodoTableViewController: UISearchResultsUpdating, TodoCellDelegate {
    func checkmarkTapped(for cell: TodoTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        let category = categories[indexPath.section]
        let selectedItem = categorizedItems[category]![indexPath.row]
        toggleItemCompletion(selectedItem)
    }
    
    func cellContentTapped(for cell: TodoTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        let category = categories[indexPath.section]
        let selectedItem = categorizedItems[category]![indexPath.row]
        editTodoItem(selectedItem)
    }
    
    // 검색 컨트롤러 설정
    func configureSearchController() {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "검색"
        navigationItem.searchController = searchController
        
        // 네비게이션 바에 검색바가 숨겨지지 않도록 설정
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // 검색 결과 화면을 현재 뷰 컨트롤러로 설정
        definesPresentationContext = true
    }
    
    // 검색 기능 구현
    func searchTodoItems(_ todo: String) {
        // 검색어가 없을 때 전체 데이터 로드
        if todo.isEmpty {
            loadTodoItems()
            return
        }
        
        let request: NSFetchRequest<TodoItemEntity> = TodoItemEntity.fetchRequest()
        
        request.predicate = NSPredicate(format: "todo CONTAINS[cd] %@", todo)
        
        do {
            let result = try viewContext.fetch(request)
            items = result.compactMap { TodoItem.from($0) }
            organizeCategorizedItems()
            tableView.reloadData()
        } catch {
            print("검색 실패: \(error)")
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let todo = searchController.searchBar.text else { return }
        searchTodoItems(todo)
    }
}



#Preview {
    UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!
}
