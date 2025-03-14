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
    
    @State var vm = TodoViewModel()
    
    var body: some View {
        Authenticator { state in
            VStack {
                Button("Sign out") {
                    Task {
                        await state.signOut()
                    }
                }
                
                List {
                    ForEach($vm.todos, id: \.id) { todo in
                        TodoRow(todo: todo)
                            .environment(vm)
                    }
                    .onDelete { indexSet in
                        Task { await vm.deleteTodos(indexSet: indexSet) }
                    }
                }
                .task {
                    vm.subscribe()
                    await vm.listTodos()
                }
                Button(action: {
                    Task { await vm.createTodo() }
                }) {
                    HStack {
                        Text("Add a New Todo")
                        Image(systemName: "plus")
                    }
                }
                .accessibilityLabel("New Todo")
            }
        }
    }
}

#Preview {
    ContentView()
}
