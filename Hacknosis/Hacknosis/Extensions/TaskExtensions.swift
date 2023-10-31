//
//  TaskExtensions.swift
//  Core Content
//
//  Created by Gopireddy Amarnath Reddy on 23/08/23.
//

import Foundation

extension Task where Failure == Error {
    @discardableResult
    static func retrying(
        priority: TaskPriority? = nil,
        maxRetryCount: Int = 2,
        retryDelay: TimeInterval = 2,
        shouldCancelRetry: (()->Bool)? = nil,
        operation: @Sendable @escaping (Bool) async throws -> Success
    ) -> Task {
        Task(priority: priority) {
            for _ in 0..<maxRetryCount {
                if shouldCancelRetry?() == true {
                    break
                }
                do {
                    return try await operation(false)
                } catch {
                    let oneSecond = TimeInterval(1_000_000_000)
                    let delay = UInt64(oneSecond * retryDelay)
                    try await Task<Never, Never>.sleep(nanoseconds: delay)
                    continue
                }
            }
            try Task<Never, Never>.checkCancellation()
            return try await operation(true)
        }
    }
}
