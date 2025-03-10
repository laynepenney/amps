//
//  TodoViewModel.swift
//  Amps
//
//  Created by Layne Penney on 3/10/25.
//

import Amplify
import SwiftUI

@MainActor
class TodoViewModel: ObservableObject {
    @Published var todos: [Todo] = []

    func createTodo() async {
        let creationTime = Temporal.DateTime.now()
        let todo = Todo(
            content: "Random Todo \(creationTime.iso8601String)",
            isDone: false,
            createdAt: creationTime,
            updatedAt: creationTime
        )
        do {
            let result = try await Amplify.API.mutate(request: .create(todo))
            switch result {
            case .success(let todo):
                print("Successfully created todo: \(todo)")
                todos.append(todo)
            case .failure(let error):
                print("Got failed result with \(error.errorDescription)")
            }
        } catch let error as APIError {
            print("Failed to create todo: ", error)
        } catch {
            print("Unexpected error: \(error)")
        }
    }
    
    func listTodos() async {
        let request = GraphQLRequest<Todo>.list(Todo.self)
        do {
            let result = try await Amplify.API.query(request: request)
            switch result {
            case .success(let todos):
                print("Successfully retrieved list of todos: \(todos)")
                self.todos = todos.elements
            case .failure(let error):
                print("Got failed result with \(error.errorDescription)")
            }
        } catch let error as APIError {
            print("Failed to query list of todos: ", error)
        } catch {
            print("Unexpected error: \(error)")
        }
    }
    
    func deleteTodos(indexSet: IndexSet) async {
        for index in indexSet {
            do {
                let todo = todos[index]
                let result = try await Amplify.API.mutate(request: .delete(todo))
                switch result {
                case .success(let todo):
                    print("Successfully deleted todo: \(todo)")
                    todos.remove(at: index)
                case .failure(let error):
                    print("Got failed result with \(error.errorDescription)")
                }
            } catch let error as APIError {
                print("Failed to deleted todo: ", error)
            } catch {
                print("Unexpected error: \(error)")
            }
        }
    }

    func updateTodo(todo: Todo) async {
        do {
            let result = try await Amplify.API.mutate(request: .update(todo))
            switch result {
            case .success(let todo):
                print("Successfully updated todo: \(todo)")
            case .failure(let error):
                print("Got failed result with \(error.errorDescription)")
            }
        } catch let error as APIError {
            print("Failed to updated todo: ", error)
        } catch {
            print("Unexpected error: \(error)")
        }
    }
}
