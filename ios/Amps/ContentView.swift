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
                    ForEach($vm.todos) { todo in
                        let value = todo.wrappedValue
                        TodoRow(id: value.id, content: value.content, isDone: todo.isDone)
                          .environment(vm)
                    }
                    .onDelete { indexSet in
                        Task { await vm.deleteTodos(indexSet: indexSet) }
                    }
                }.refreshable {
                    await vm.listTodos()
                }.onChange(of: vm.todos) { oldValue, newValue in
                    print("onChange: \(oldValue) -> \(newValue)")
                }.task {
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
