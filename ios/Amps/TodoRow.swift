//
//  TodoRow.swift
//  Amps
//
//  Created by Layne Penney on 3/10/25.
//

import SwiftUI

struct TodoRow: View {
    @Environment(TodoViewModel.self) var vm: TodoViewModel!
    let id: String
    var content: String?
    @Binding var isDone: Bool

    var body: some View {
        Toggle(isOn: $isDone) {
            Text(content ?? "")
        }
        .toggleStyle(.switch)
        .onChange(of: isDone) { _, newValue in
            let change = Todo(id:id, content: content, isDone: newValue)
            Task { await vm.updateTodo(todo: change) }
        }
    }
}

#Preview {
    let vm = TodoViewModel()
    @State var todo = Todo(content: "Hello Todo World 20240706T15:23:42.256Z", isDone: false)
    return TodoRow(id: todo.id, content: todo.content, isDone: $todo.isDone)
        .environment(vm)
}
