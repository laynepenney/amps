//
//  TodoRow.swift
//  Amps
//
//  Created by Layne Penney on 3/10/25.
//

import SwiftUI

struct TodoRow: View {
    @ObservedObject var vm: TodoViewModel
    @Binding var todo: Todo

    var body: some View {
        Toggle(isOn: $todo.isDone) {
            Text(todo.content ?? "")
        }
        .toggleStyle(.switch)
        .onChange(of: todo.isDone) { _, newValue in
            var updatedTodo = todo
            updatedTodo.isDone = newValue
            Task { await vm.updateTodo(todo: updatedTodo) }
        }
    }
}

#Preview {
    @State var todo = Todo(content: "Hello Todo World 20240706T15:23:42.256Z", isDone: false)
    return TodoRow(vm: TodoViewModel(), todo: $todo)
}
