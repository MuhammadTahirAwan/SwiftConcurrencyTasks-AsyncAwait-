//
//  SwiftUIView.swift
//  AsyncAwaitFinalTask
//
//  Created by Nikolay Dechko on 4/9/24.
//

import SwiftUI

struct Task1View: View, @unchecked Sendable {
    let task1API = Task1API()
    @State var fact = "To get random number fact presss button below"

    var body: some View {
        VStack {
            Text(fact)
                .padding()
            Button(action: {
                Task {
                    let fact = await task1API.getTrivia(for: nil)
                    self.fact = fact ?? "loading error"
                }
            }, label: { Text("Click me") })
        }
    }
}

#Preview {
    Task1View()
}

class Task1API: @unchecked Sendable {
    let baseURL = "http://numbersapi.com"
    let triviaPath = "random/trivia"
    private let session = URLSession.shared

    func getTrivia(for number: Int?) async -> String? {
        guard let url = URL(string: baseURL)?.appendingPathComponent(triviaPath) else {
            return nil
        }
        print(url)
        
        do {
            let (data, _) = try await session.data(from: url)
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }

}
