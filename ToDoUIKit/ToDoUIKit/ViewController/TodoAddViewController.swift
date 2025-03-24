//
//  TodoAddViewController.swift
//  ToDoUIKit
//
//  Created by NO SEONGGYEONG on 3/21/25.
//

import UIKit
import CoreData

class TodoAddViewController: UIViewController {
    
    var editMode = false
    var todoItemToEdit: TodoItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        view.backgroundColor = .systemBackground
        title = editMode ? "할 일 수정" : "할 일 추가"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelButtonTapped)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(saveButtonTapped)
        )
        
        if editMode, let item = todoItemToEdit {
            fillFieds(with: item)
        }
    }
    
    private func fillFieds(with item: TodoItem) {
        titleTextField.text = item.todo
        datePicker.date = item.setTime
        categoryTextField.text = item.category
        
        let priorities = ["Low", "Medium", "High"]
        if let priorityIndex = priorities.firstIndex(of: item.priority) {
            prioritySegmentdControl.selectedSegmentIndex = priorityIndex
        }
    }
    
    
    private var persistentContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    
    private var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "할 일을 입력해주세요"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()
    
    private let prioritySegmentdControl: UISegmentedControl = {
        let segmentdControl = UISegmentedControl(items: ["Low", "Medium", "High"])
        segmentdControl.selectedSegmentIndex = 0
        segmentdControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentdControl
    }()
    
    private let categoryTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "카테고리를 입력해주세요"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    
    private func setupUI() {
        view.addSubview(titleTextField)
        view.addSubview(categoryTextField)
        view.addSubview(datePicker)
        view.addSubview(prioritySegmentdControl)
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            categoryTextField.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
            categoryTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            categoryTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            datePicker.topAnchor.constraint(equalTo: categoryTextField.bottomAnchor, constant: 20),
            datePicker.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            datePicker.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            prioritySegmentdControl.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 20),
            prioritySegmentdControl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            prioritySegmentdControl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
        ])
    }
    
    @objc func saveButtonTapped() {
        guard let todo = titleTextField.text, !todo.isEmpty else { return }
        let priorities = ["Low", "Medium", "High"]
        let selectedPriority = priorities[prioritySegmentdControl.selectedSegmentIndex]
        
        let newTodo = TodoItemEntity(context: viewContext)
        newTodo.id = UUID()
        newTodo.todo = todo
        newTodo.isDone = false
        newTodo.createdAt = Date()
        newTodo.priority = selectedPriority
        newTodo.setTime = datePicker.date
        newTodo.category = categoryTextField.text ?? ""
        do {
            try viewContext.save()
            print("저장 성공")
            dismiss(animated: true)
        } catch {
            print("저장 실패: \(error.localizedDescription)")
        }
    }
    
    
    @objc func cancelButtonTapped() {
        dismiss(animated: true)
    }
}

#Preview {
//    UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!
    TodoAddViewController()
}


