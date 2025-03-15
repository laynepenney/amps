//
//  TodoViewModel.swift
//  Amps
//
//  Created by Layne Penney on 3/10/25.
//

import SwiftUI
import Amplify
import OrderedCollections

@MainActor
@Observable
class TodoViewModel {
    var todos: Array<Todo> = []
    
    private var onCreate = Subscription(.onCreate)
    private var onDelete = Subscription(.onDelete)
    private var onUpdate = Subscription(.onUpdate)
    
    deinit {
        Task { [weak self] in
            await self?.onCreate.cancel()
            await self?.onDelete.cancel()
            await self?.onUpdate.cancel()
        }
    }

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
                await self.update(todo)
            case .failure(let error):
                print("Got failed result with \(error.errorDescription)")
            }
        } catch let error as APIError {
            print("Failed to create todo: ", error)
        } catch {
            print("Unexpected error: \(error)")
        }
    }
    
    private func update(_ todo: Todo) async {
        guard let index = self.todos.firstIndex(where: { test in todo.id == test.id }) else {
            self.todos.append(todo)
            return
        }
        
        self.todos[index] = todo
    }
    
    private func remove(_ todo: Todo) async {
        // TODO: determine how to handle case where removing last element causes index out of bounds fatal error
        // make a copy
//        let copy = self.todos
//        let begin = copy.startIndex
//        let end = copy.endIndex-1
//        let found = copy.firstIndex(of: todo)
//        if found == end {
//            self.todos.insert(self.todos.remove(at: begin), at: begin)
////            self.todos.append(todo)
//            self.todos.remove(at: end)
//            
//            
////            self.todos = Array(copy[begin..<end])
////            self._data = OrderedSet(self.todos)
//            self._data = OrderedSet(copy[..<end])
//            return
//        }
        guard let index = self.todos.firstIndex(where: { test in todo.id == test.id }) else {
            return
        }
        
        self.todos.remove(at: index)
    }
    
    func subscribe() {
        onCreate.subscribe { [unowned self] todo in
            await self.update(todo)
        }
        onDelete.subscribe { [unowned self] todo in
            await self.remove(todo)
        }
        onUpdate.subscribe { [unowned self] todo in
            await self.update(todo)
        }
    }
    
    func listTodos() async {
        let request = GraphQLRequest<Todo>.list(Todo.self)
        do {
            let result = try await Amplify.API.query(request: request)
            switch result {
            case .success(let todos):
                print("Successfully retrieved list of todos: \(todos)")
                self.todos = Array(todos)
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
                let todo = self.todos[index]
                let result = try await Amplify.API.mutate(request: .delete(todo))
                switch result {
                case .success(let todo):
                    print("Successfully deleted todo: \(todo)")
                    await self.remove(todo)
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
                await self.update(todo)
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

extension Todo: Hashable, Equatable {
    public static func == (lhs: Todo, rhs: Todo) -> Bool {
        return lhs.id == rhs.id
        && lhs.content == rhs.content
        && lhs.isDone == rhs.isDone
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
        hasher.combine(self.content)
        hasher.combine(self.isDone)
    }
}

extension Todo: Identifiable {
    public typealias ID = String
}

@MainActor
struct Subscription {
    let type: GraphQLSubscriptionType
    let subscription: AmplifyAsyncThrowingSequence<GraphQLSubscriptionEvent<Todo>>
    private var task: Task<Void, Error>?
    
    init(_ type: GraphQLSubscriptionType) {
        let request: GraphQLRequest<Todo> = .subscription(of: Todo.self, type: type)
        self.type = type
        self.subscription = Amplify.API.subscribe(request: request)
    }
    
    @discardableResult
    mutating func subscribe(_ callback: @escaping (Todo)async ->Void) -> Task<Void, Error> {
        if let task = self.task {
            return task
        }
        let task = Task { [self, callback] in
            try await self.doSubscribe(callback)
        }
        self.task = task
        return task
    }
    
    func cancel() {
        task?.cancel()
        subscription.cancel()
    }
    
    func isCancelled() -> Bool {
        return subscription.isCancelled
    }
    
    private func doSubscribe(_ callback: (Todo) async ->Void) async throws {
        do {
            for try await subscriptionEvent in subscription {
                switch subscriptionEvent {
                case .connection(let subscriptionConnectionState):
                    print("Subscription \(type) connect state is \(subscriptionConnectionState)")
                case .data(let result):
                    switch result {
                    case .success(let createdTodo):
                        print("Successfully got \(type) todo from subscription: \(createdTodo)")
                        await callback(createdTodo)
                    case .failure(let error):
                        print("Got failed result with \(error.errorDescription)")
                    }
                }
            }
        } catch {
            print("Subscription has terminated with \(error)")
            throw error
        }
    }
}
