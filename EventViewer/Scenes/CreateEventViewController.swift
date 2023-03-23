//
//  CreateEventViewController.swift
//  EventViewer
//
//  Created by Raman Kozar on 22/03/2023.
//  Updated by Raman Kozar
//

import UIKit
import Foundation

final class CreateEventViewController: UIViewController {

    private let eventManager: EventManager
    var newOffset: Int?
    
    private var currentVC: EventsListViewController?
    private var delegateForUpdateEvents: EventsListViewController!
    
    private let idTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let createdAtField: UITextField = {
        let createdAtField = UITextField()
        createdAtField.translatesAutoresizingMaskIntoConstraints = false
        return createdAtField
    }()
    
    private let parametersTextField: UITextField = {
        let parametersTextField = UITextField()
        parametersTextField.translatesAutoresizingMaskIntoConstraints = false
        return parametersTextField
    }()
    
    private let mainLabel: UILabel = {
        let mainLabel = UILabel()
        mainLabel.font = UIFont.boldSystemFont(ofSize: 25.0)
        mainLabel.translatesAutoresizingMaskIntoConstraints = false
        return mainLabel
    }()
    
    private let idLabel: UILabel = {
        let idLabel = UILabel()
        idLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        idLabel.translatesAutoresizingMaskIntoConstraints = false
        return idLabel
    }()
    
    private let createdAtFieldLabel: UILabel = {
        let createdAtFieldLabel = UILabel()
        createdAtFieldLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        createdAtFieldLabel.translatesAutoresizingMaskIntoConstraints = false
        return createdAtFieldLabel
    }()
    
    private let parametersLabel: UILabel = {
        let parametersLabel = UILabel()
        parametersLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        parametersLabel.translatesAutoresizingMaskIntoConstraints = false
        return parametersLabel
    }()
    
    private let createButton: UIButton = {
        
        let button = UIButton(type: .custom)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .blue
        
        button.setTitle(" Create ", for: .normal)
        button.titleLabel?.font = UIFont(name: "Arial", size: 17)
       
        button.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        
        button.layer.cornerRadius = 9
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.blue.cgColor
        
        return button
        
    }()
    
    let datePicker = UIDatePicker()
    
    init(eventManager: EventManager, currentVC: EventsListViewController, newOffset: Int) {
        self.eventManager = eventManager
        self.currentVC = currentVC
        self.newOffset = newOffset
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
        
    func setupLayout() {
        
        setupDatePicker()
        
        view.backgroundColor = .white
        
        let stackFirst = UIStackView()
        stackFirst.axis = NSLayoutConstraint.Axis.vertical
        stackFirst.distribution = UIStackView.Distribution.equalSpacing
        stackFirst.alignment = UIStackView.Alignment.center
        stackFirst.spacing = 5.0
        
        stackFirst.addArrangedSubview(idLabel)
        stackFirst.addArrangedSubview(idTextField)
        stackFirst.translatesAutoresizingMaskIntoConstraints = false
        
        let stackSecond = UIStackView()
        stackSecond.axis = NSLayoutConstraint.Axis.vertical
        stackSecond.distribution = UIStackView.Distribution.equalSpacing
        stackSecond.alignment = UIStackView.Alignment.center
        stackSecond.spacing = 5.0
        
        stackSecond.addArrangedSubview(createdAtFieldLabel)
        stackSecond.addArrangedSubview(createdAtField)
        stackSecond.translatesAutoresizingMaskIntoConstraints = false
        
        let stackThird = UIStackView()
        stackThird.axis = NSLayoutConstraint.Axis.vertical
        stackThird.distribution = UIStackView.Distribution.equalSpacing
        stackThird.alignment = UIStackView.Alignment.center
        stackThird.spacing = 5.0
        
        stackThird.addArrangedSubview(parametersLabel)
        stackThird.addArrangedSubview(parametersTextField)
        stackThird.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(createButton)
        view.addSubview(mainLabel)
        view.addSubview(stackFirst)
        view.addSubview(stackSecond)
        view.addSubview(stackThird)
        
        NSLayoutConstraint.activate([
            
            createButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            
            mainLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -270),
            
            stackFirst.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackFirst.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            
            stackSecond.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackSecond.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            stackThird.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackThird.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 100)
            
        ])
        
    }
    
    private func setupViews() {
        
        idTextField.placeholder = "write ID of the new event.."
        createdAtField.placeholder = "choose the date.."
        parametersTextField.placeholder = "create using format key1:value1;"
        mainLabel.text = "Create new custom event"
        idLabel.text = "Event ID:"
        createdAtFieldLabel.text = "Event date/time:"
        parametersLabel.text = "Parameters at JSON:"
        
        createButton.addTarget(self, action: #selector(createButtonEvent), for: .touchUpInside)
        
    }
    
    func setupDatePicker() {
        
        // formate Date
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        // toolbar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        
        let doneButton = UIBarButtonItem(title: "Done",
                                         style: .plain,
                                         target: self,
                                         action: #selector(doneDatePicker));
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace,
                                          target: nil,
                                          action: nil)
        
        let cancelButton = UIBarButtonItem(title: "Cancel",
                                           style: .plain,
                                           target: self,
                                           action: #selector(cancelDatePicker));
        
        toolbar.setItems([doneButton, spaceButton, cancelButton], animated: false)
        
        createdAtField.inputAccessoryView = toolbar
        createdAtField.inputView = datePicker
        
    }
    
    @objc func doneDatePicker() {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        
        createdAtField.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
        
    }
    
    @objc func cancelDatePicker() {
        self.view.endEditing(true)
    }
    
    @objc func createButtonEvent(sender: UIButton!) {
        
        guard let id = idTextField.text else { return }
        guard let createdAtString = createdAtField.text else { return }
        guard let parameters = parametersTextField.text else { return }
        
        if !id.isEmpty && !createdAtString.isEmpty {
         
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
            
            let createdAt = formatter.date(from: createdAtString)
            
            var parametersDict = ParameterSet()
            
            if !parameters.isEmpty {
            
                let arrayOfStrings = parameters.components(separatedBy: ";")
                
                for valueOfArray in arrayOfStrings {
                    
                    let currVal = valueOfArray.components(separatedBy: ":")
                    parametersDict[currVal[0]] = .string(currVal[1])
                    
                }
                
            }
            
            let newDBEvent = Event(id: id, parameters: parametersDict)
            
            eventManager.captureCustomEvent(newDBEvent, dateOfEvent: createdAt!)
            
            self.delegateForUpdateEvents = self.currentVC
            
            guard let newOffset = newOffset else { return }
            self.delegateForUpdateEvents.reloadDataAndUpdateTableView(newOffset: newOffset + 20)
            
            self.dismiss(animated: true, completion: nil)
            
        }
        
    }
    
}

