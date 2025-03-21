//
//  TodoTableViewCell.swift
//  ToDoUIKit
//
//  Created by NO SEONGGYEONG on 3/21/25.
//

import UIKit


protocol TodoCellDelegate: AnyObject {
    func checkmarkTapped(for cell: TodoTableViewCell)
    func cellContentTapped(for cell: TodoTableViewCell)
}

class TodoTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "TodoTableViewCell"
    
    weak var delegate: TodoCellDelegate?
    
    // 체크마크 버튼
    private let checkmarkButton = UIButton(type: .system)
    private let priorityLabel = UILabel()
    
    // 셀 내용 영역
    private let contentStack = UIStackView()
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    
    // 전체 영역 터치를 위한 버튼
    private let contentTapButton = UIButton(type: .system)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        // 체크마크 버튼 설정
        checkmarkButton.translatesAutoresizingMaskIntoConstraints = false
        checkmarkButton.tintColor = .systemGray
        checkmarkButton.addTarget(self, action: #selector(checkmarkTapped), for: .touchUpInside)
        
        // 우선순위 레이블 설정
        priorityLabel.translatesAutoresizingMaskIntoConstraints = false
        priorityLabel.textColor = .systemGray
        
        // 제목 레이블 설정
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        
        // 날짜 레이블 설정
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        dateLabel.textColor = .systemGray
        
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 4
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(dateLabel)
        
        // 콘텐츠 탭 버튼 설정
        contentTapButton.translatesAutoresizingMaskIntoConstraints = false
        contentTapButton.backgroundColor = .clear
        contentTapButton.addTarget(self, action: #selector(contentAreaTapped), for: .touchUpInside)
        
        // 뷰 계층 구조 설정
        contentView.addSubview(checkmarkButton)
        contentView.addSubview(contentStack)
        contentView.addSubview(priorityLabel)
        contentView.addSubview(contentTapButton)
        
        // 제약 조건 설정
        NSLayoutConstraint.activate([
            checkmarkButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            checkmarkButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkmarkButton.widthAnchor.constraint(equalToConstant: 30),
            checkmarkButton.heightAnchor.constraint(equalToConstant: 30),
            
            contentStack.leadingAnchor.constraint(equalTo: checkmarkButton.trailingAnchor, constant: 12),
            contentStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            contentStack.trailingAnchor.constraint(equalTo: priorityLabel.trailingAnchor, constant: -12),
            
            priorityLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            priorityLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            // 콘텐츠 탭 버튼은 체크마크를 제외한 모든 영역을 덮음
            contentTapButton.leadingAnchor.constraint(equalTo: checkmarkButton.trailingAnchor),
            contentTapButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentTapButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentTapButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    func configure(with item: TodoItem) {
        // 체크마크 이미지 설정
        let imageName = item.isDone ? "checkmark.circle.fill" : "circle"
        checkmarkButton.setImage(UIImage(systemName: imageName), for: .normal)
        checkmarkButton.tintColor = .systemGray
        
        contentView.backgroundColor = item.isDone ? .systemGray.withAlphaComponent(0.5) : .white
        if !item.isDone {
            switch item.priority {
            case "Low":
                priorityLabel.textColor = .systemGreen
            case "Medium":
                priorityLabel.textColor = .systemYellow
            case "High":
                priorityLabel.textColor = .systemRed
            default:
                priorityLabel.textColor = .clear
                break
            }
        }
        // 텍스트 설정
        titleLabel.text = item.todo
        
        // 날짜 포맷 설정
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateLabel.text = dateFormatter.string(from: item.setTime)
        priorityLabel.text = item.priority
    }
    
    @objc private func checkmarkTapped() {
        delegate?.checkmarkTapped(for: self)
    }
    
    @objc private func contentAreaTapped() {
        delegate?.cellContentTapped(for: self)
    }
}


#Preview {
    UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!
}




