//
//  EventsListViewController.swift
//  EventViewer
//
//  Created by Ilya Kharlamov on 1/26/23.
//

import UIKit

class EventsListViewController: UITableViewController {
    
    let myTableView = UITableView()
    
    var arrayOfInformation: [String] = []
    
    // MARK: - Outlets

    private lazy var logoutBarButtonItem = UIBarButtonItem(
        title: "Logout",
        style: .plain,
        target: self,
        action: #selector(EventsListViewController.logout)
    )
    
    // MARK: - Variables
    
    private let eventManager: EventManager

    // MARK: - Lifecycle
    
    init(eventManager: EventManager) {
        self.eventManager = eventManager
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        arrayOfInformation = eventManager.getAllTheEvents(countLimit: 20)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        eventManager.capture(.viewScreen("EVENTS_LIST"))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        myTableView.frame = view.bounds
    }

    // MARK: - Configuration
    
    private func configureUI() {
        
        navigationItem.title = "Events List"
        navigationItem.rightBarButtonItem = self.logoutBarButtonItem
        
        myTableView.delegate = self
        myTableView.dataSource = self
        
        myTableView.register(Cell.self, forCellReuseIdentifier: Cell.identifier)
        
        view.addSubview(myTableView)
        
    }
    
    // MARK: - Actions
    
    @objc
    private func logout() {
        eventManager.capture(.logout)
        let vc = LoginViewController(eventManager: eventManager)
        let navVc = UINavigationController(rootViewController: vc)
        present(navVc, animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfInformation.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let currCell = myTableView.dequeueReusableCell(withIdentifier: Cell.identifier, for: indexPath) as? Cell
        else {
            return UITableViewCell()
        }
    
        currCell.myLabel.text = arrayOfInformation[indexPath.row]
        
        return currCell
        
    }
        
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y + scrollView.frame.height >= scrollView.contentSize.height {
            arrayOfInformation += eventManager.getAllTheEvents(countLimit: 20)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, handler) in
            if self.eventManager.deleteEvent(currentIndex: indexPath.row) {
                self.arrayOfInformation.remove(at: indexPath.row)
                handler(true)
            }
        }
        
        deleteAction.backgroundColor = .red
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        
        return configuration
        
    }
    
}
