//
//  LoginViewController.swift
//  EventViewer
//
//  Created by Ilya Kharlamov on 1/26/23.
//

import UIKit
import SnapKit

class LoginViewController: UIViewController {
    
    // MARK: - Outlets
    
    private lazy var loginButton = UIButton(
        type: .system,
        primaryAction: UIAction(
            title: "Login",
            handler: { [weak self] _ in
                self?.login()
            }
        )
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
        configureSubviews()
        configureConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        eventManager.capture(.viewScreen("LOGIN_FORM"))
    }
    
    // MARK: - Configuration
    
    private func configureUI() {
        navigationItem.title = "Login"
        view.backgroundColor = .systemBackground
    }
    
    private func configureSubviews() {
        view.addSubview(self.loginButton)
    }
    
    private func configureConstraints() {
        loginButton.snp.makeConstraints({ maker in
            maker.center.equalToSuperview()
        })
    }
    
    // MARK: - Actions
    
    private func login() {
        eventManager.capture(.login)
        dismiss(animated: true)
    }
    
}
