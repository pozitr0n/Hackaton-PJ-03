//
//  EventRegistry.swift
//  EventsManager
//
//  Created by Ilya Kharlamov on 11/29/22.
//  Copyright © 2022 DIGITAL RETAIL TECHNOLOGIES, S.L. All rights reserved.
//

import Foundation

public extension Event {

    static var signUp: Event {
        Event(id: "SIGN_UP")
    }

    static var login: Event {
        Event(id: "LOGIN")
    }

    static var logout: Event {
        Event(id: "LOGOUT")
    }

    static func viewScreen(_ screenId: String) -> Event {
        Event(id: "VIEW_SCREEN", parameters: [
            "SCREEN_ID": .string(screenId)
        ])
    }

}
