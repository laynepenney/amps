//
//  AmpsApp.swift
//  Amps
//
//  Created by Layne Penney on 3/10/25.
//

import SwiftUI
import Amplify
import Authenticator
import AWSCognitoAuthPlugin

@main
struct AmpsApp: App {
    init() {
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.configure(with: .amplifyOutputs)
        } catch {
            print("Unable to configure Amplify \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
