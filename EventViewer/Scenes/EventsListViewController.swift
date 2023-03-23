//
//  EventsListViewController.swift
//  EventViewer
//
//  Created by Ilya Kharlamov on 1/26/23.
//  Updated by Raman Kozar
//  Updated by Raman Kozar
//

import UIKit
import CoreData

protocol TableViewMyDelegate {
    func deleteEventUpdateTableView(currentIndexPathItem: Int)
    func reloadDataAndUpdateTableView(newOffset: Int)
}

class EventsListViewController: UIViewController {
    
    private let myTableView = UITableView(frame: .zero, style: .insetGrouped)
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var entities: [NSManagedObject] = [] {
        didSet {
            updateTableView()
        }
    }
    
    private var filteredEntities: [NSManagedObject] = []
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    var offset = 0
    
    // MARK: - Outlets

    private lazy var logoutBarButtonItem = UIBarButtonItem(
        title: "Logout",
        style: .plain,
        target: self,
        action: #selector(EventsListViewController.logout)
    )
    
    private lazy var addNewEventBarButtonItem = UIBarButtonItem(
        title: "Add event",
        style: .plain,
        target: self,
        action: #selector(EventsListViewController.addNewEvent)
    )
    
    // MARK: - Variables
    
    private let eventManager: EventManager

    // MARK: - Lifecycle
    
    init(eventManager: EventManager) {
        self.eventManager = eventManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureSearchController()
        loadData()
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
        navigationItem.leftBarButtonItem = self.addNewEventBarButtonItem
        
        myTableView.delegate = self
        myTableView.dataSource = self
        
        myTableView.register(Cell.self, forCellReuseIdentifier: Cell.identifier)
        
        view.addSubview(myTableView)
        
    }
    
    // MARK: - Actions
    
    @objc private func logout() {
        eventManager.capture(.logout)
        let vc = LoginViewController(eventManager: eventManager)
        let navVc = UINavigationController(rootViewController: vc)
        present(navVc, animated: true)
    }
    
    @objc private func addNewEvent() {
        let vc = CreateEventViewController(eventManager: eventManager, currentVC: self, newOffset: offset)
        let navVc = UINavigationController(rootViewController: vc)
        present(navVc, animated: true)
    }
    
    private func loadData() {
        guard let data = eventManager.fetch(with: offset) else { return }
        entities.append(contentsOf: data)
    }
    
    private func configureSearchController() {
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    func configureCell(cell: Cell, atIndexPath indexPath: IndexPath) {

        var entity: NSManagedObject

        if isFiltering {
            entity = filteredEntities[indexPath.row]
        } else {
            entity = entities[indexPath.row]
        }
        
        guard let entity = entity as? DBEvent,
              let createdAt = entity.createdAt else { return }
            
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
            
        let value = "\(dateFormatter.string(from: createdAt)): \(entity.id)"

        cell.myLabel.text = value
    }
    
}

extension EventsListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFiltering {
            return filteredEntities.count
        }
        
        return entities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let currCell = myTableView.dequeueReusableCell(withIdentifier: Cell.identifier, for: indexPath) as? Cell
        else {
            return UITableViewCell()
        }
    
        configureCell(cell: currCell, atIndexPath: indexPath)
        
        return currCell
        
    }
}

extension EventsListViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y + scrollView.frame.height >= scrollView.contentSize.height {
            
            offset += 20
            guard let newEntities = eventManager.fetch(with: offset),
                  newEntities.count > 0 else { return }
            
            entities.append(contentsOf: newEntities)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, handler) in
            
            self.eventManager.delete(with: self.entities[indexPath.item].objectID) { error in
                
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                self.entities.remove(at: indexPath.item)
            }
        }
        
        deleteAction.backgroundColor = .red
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        
        return configuration
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let event = entities[indexPath.item] as? DBEvent else { return }
        
        let vc = DetailEventViewController(event: event, currentIndexPathItem: indexPath.item, currentVC: self)
        present(vc, animated: true)
        
    }
}

extension EventsListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text ?? "")
    }
    
    private func filterContentForSearchText(_ searchText: String) {
    
        guard let entities = eventManager.search(with: searchText) else { return }
        
        filteredEntities = entities
        updateTableView()
        
    }
}

extension EventsListViewController: TableViewMyDelegate {
    
    func deleteEventUpdateTableView(currentIndexPathItem: Int) {
        entities.remove(at: currentIndexPathItem)
        updateTableView()
    }
    
    func reloadDataAndUpdateTableView(newOffset: Int) {
        guard let newEntities = eventManager.fetch(with: newOffset),
              newEntities.count > 0 else { return }
        
        entities.append(contentsOf: newEntities)
    }
    
    func updateTableView() {
        myTableView.reloadData()
    }
    
}
