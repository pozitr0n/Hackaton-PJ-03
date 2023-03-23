//
//  DetailEventViewController.swift
//  EventViewer
//
//  Created by Vladislav Panev on 15.03.2023.
//  Updated by Raman Kozar
//

import UIKit
import SnapKit

final class DetailEventViewController: UIViewController {
    
    private var event: DBEvent?
    private var currentIndexPathItem: Int?
    private var currentVC: EventsListViewController?
    private var params: [DBParameter] = []
    private var delegateForUpdateEvents: EventsListViewController!
    
    private let idLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.contentInset = .init(top: 0, left: 0, bottom: 16, right: 16)
        tableView.register(
            Cell.self,
            forCellReuseIdentifier: Cell.identifier
        )
        tableView.dataSource = self
        return tableView
    }()
    
    private let deleteButton: UIButton = {
        
        let button = UIButton(type: .custom)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .red
       
        button.setTitle("   Delete event   ", for: .normal)
        button.titleLabel?.font = UIFont(name: "Arial", size: 17)
       
        button.setImage(UIImage(systemName: "delete.left"), for: .normal)
        
        button.layer.cornerRadius = 9
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.blue.cgColor
        
        return button
        
    }()

    init(event: DBEvent, currentIndexPathItem: Int, currentVC: EventsListViewController) {
        self.event = event
        self.currentIndexPathItem = currentIndexPathItem
        self.currentVC = currentVC
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupViews()
    }

    private func setupLayout() {
        
        view.backgroundColor = .white
        
        view.addSubview(deleteButton)
        view.addSubview(idLabel)
        view.addSubview(dateLabel)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
        
            deleteButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            deleteButton.bottomAnchor.constraint(equalTo: idLabel.topAnchor, constant: -30),
            deleteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            idLabel.topAnchor.constraint(equalTo: deleteButton.bottomAnchor, constant: 20),
            idLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            idLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 10),
            idLabel.bottomAnchor.constraint(equalTo: dateLabel.topAnchor, constant: -30),
            
            dateLabel.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: 20),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 10),
            dateLabel.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -30),
            
            tableView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        
        ])
        
    }
    
    @objc func deleteThisEvent(sender: UIButton!) {
            
        guard let objectId = event?.objectID else { return }
        
        let eventManager = EventManager()
        
        eventManager.delete(with: objectId) { error in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            self.delegateForUpdateEvents = self.currentVC
            
            guard let currentIndexPathItem = self.currentIndexPathItem else { return }
            self.delegateForUpdateEvents.deleteEventUpdateTableView(currentIndexPathItem: currentIndexPathItem)
            
            self.dismiss(animated: true, completion: nil)
            
        }
        
    }
    
    private func setupViews() {
        
        guard let textEventId = event?.id else { return }
        idLabel.text = "Current event: " + textEventId
        
        guard let createdAt = event?.createdAt else { return }
            
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        
        dateLabel.text = "Current date: " + dateFormatter.string(from: createdAt)
        
        params = Array((event?.parameters!)!)
        
        deleteButton.addTarget(self, action: #selector(deleteThisEvent), for: .touchUpInside)
        
    }
}

extension DetailEventViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        params.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Cell.identifier, for: indexPath) as? Cell else { return UITableViewCell() }
        
        cell.myLabel.text = params[indexPath.item].key
        
        return cell
        
    }
    
}
