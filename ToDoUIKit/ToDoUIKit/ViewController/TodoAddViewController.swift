//
//  TodoAddViewController.swift
//  ToDoUIKit
//
//  Created by NO SEONGGYEONG on 3/21/25.
//

import UIKit
import CoreData

class TodoAddViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        view.backgroundColor = .systemBackground
        title = "할 일 추가"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelButtonTapped)
        )
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
    
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("저장", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
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
        view.addSubview(saveButton)
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
            
            saveButton.topAnchor.constraint(equalTo: prioritySegmentdControl.bottomAnchor, constant: 20),
            saveButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 44)
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
    UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!
}


