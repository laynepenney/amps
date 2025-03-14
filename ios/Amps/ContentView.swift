//
//  ContentView.swift
//  Amps
//
//  Created by Layne Penney on 3/10/25.
//

import SwiftUI
import Amplify
import Authenticator

struct ContentView: View {
    var body: some View {
        Authenticator { state in
            VStack {
                Button("Sign out") {
                    Task {
                        await state.signOut()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
