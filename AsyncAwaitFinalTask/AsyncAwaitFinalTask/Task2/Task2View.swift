//
//  Task2View.swift
//  AsyncAwaitFinalTask
//
//  Created by Nikolay Dechko on 4/9/24.
//

import SwiftUI

struct Task2View: View {
    let task2API: Task2API = .init()

    @State var user: Task2API.User?
    @State var products: [Task2API.Product] = []
    @State var duration: TimeInterval?

    var body: some View {
        VStack {
            if let user, !products.isEmpty, let duration {
                Text("User name: \(user.name)").padding()
                List(products) { product in
                    Text("product description: \(product.description)")
                }
                Text("it took: \(duration) second(s)")
            } else {
                Text("Loading in progress")
            }
        }.task {
            do {
                let startDate = Date.now
                let dataTuple = try await task2API.fetchDashboardData()
                user = dataTuple.0
                products = dataTuple.1
                let endDate = Date.now

                duration = DateInterval(start: startDate, end: endDate).duration
            } catch {
                print("unexpected error")
            }
        }
    }
}

final class Task2API: @unchecked Sendable {
    struct User {
        let name: String
    }

    struct Product: Identifiable {
        let id: String
        let description: String
    }
    
    
    enum FetchResult: Sendable{
        
        case user(User?)
        case product([Product]?)
    }

    func getUser() async throws -> User {
        try await Task.sleep(for: .seconds(1))
        return .init(name: "John Smith")
    }

    func getProducts() async throws -> [Product] {
        try await Task.sleep(for: .seconds(1))
        return [.init(id: "1", description: "Some cool product"),
                .init(id: "2", description: "Some expensive product")]
    }
    
    func fetchDashboardData() async throws -> (User?, [Product]) {
        try await withThrowingTaskGroup(of: FetchResult.self) { group in
            group.addTask {[weak self] in
                let user = try await self?.getUser()
                return .user(user ?? nil)
            }
            
            group.addTask {[weak self] in
                let products = try await self?.getProducts()
                return .product(products ?? nil)
            }
            
            var loadedUser: User?
            var loadedProduct: [Product]?
            
            for try await result in group {
                switch result {
                case .user(let user):
                    loadedUser = user
                case .product(let products):
                    loadedProduct = products
                }
            }
            
            guard let user = loadedUser, let product = loadedProduct else {
                throw URLError(.badServerResponse)
            }
            
            return (user, product)
        }
    }
}

#Preview {
    Task2View()
}
