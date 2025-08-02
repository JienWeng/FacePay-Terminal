//
//  PaymentService.swift
//  FacePay Terminal
//
//  Created by Lai Jien Weng on 02/08/2025.
//

import Foundation
import Combine

class PaymentService: ObservableObject {
    @Published var currentState: PaymentState = .enterAmount
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let baseURL = "https://api.duitnow.com" // Replace with actual API URL
    
    // MARK: - API Calls
    
    func verifyCustomerAccount(customerName: String) async throws -> AccountResponse {
        isLoading = true
        
        // Simulate API call delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Mock response
        let mockAccount = AccountResponse(
            accountId: "ACC-\(Int.random(in: 1000...9999))",
            customerName: customerName,
            balance: Double.random(in: 100...10000),
            dailyLimit: 5000.0,
            dailySpent: Double.random(in: 0...1000),
            isActive: true
        )
        
        isLoading = false
        return mockAccount
    }
    
    func checkAccountBalance(accountId: String, amount: Double) async throws -> Bool {
        isLoading = true
        
        // Simulate API call
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Mock balance check - randomly return true/false for demo
        let hasSufficientFunds = Double.random(in: 0...1) > 0.2 // 80% success rate
        
        isLoading = false
        return hasSufficientFunds
    }
    
    func checkDailyLimit(accountId: String, amount: Double) async throws -> Bool {
        isLoading = true
        
        // Simulate API call
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // Mock limit check - simulate daily limit verification
        let currentSpent = Double.random(in: 0...1000)
        let dailyLimit = 5000.0
        let withinLimit = (currentSpent + amount) <= dailyLimit
        
        isLoading = false
        return withinLimit
    }
    
    func performFraudDetection(accountId: String, amount: Double) async throws -> FraudCheckResponse {
        isLoading = true
        
        // Simulate fraud detection API call
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Mock fraud detection - 95% legitimate transactions
        let isLegitimate = Double.random(in: 0...1) > 0.05
        let riskScore = Double.random(in: 0...100)
        
        let response = FraudCheckResponse(
            isLegitimate: isLegitimate,
            riskScore: riskScore,
            message: isLegitimate ? "Transaction approved" : "High risk transaction detected"
        )
        
        isLoading = false
        return response
    }
    
    func processPayment(accountId: String, amount: Double) async throws -> PaymentResponse {
        isLoading = true
        
        // Simulate payment processing
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        
        let response = PaymentResponse(
            transactionId: "TXN-\(UUID().uuidString.prefix(8))",
            status: "completed",
            message: "Payment successful",
            timestamp: ISO8601DateFormatter().string(from: Date())
        )
        
        isLoading = false
        return response
    }
    
    func saveTransactionRecord(transactionId: String, accountId: String, amount: Double) async throws {
        isLoading = true
        
        // Simulate saving transaction record
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // In real implementation, this would save to database
        print("Transaction record saved: \(transactionId)")
        
        isLoading = false
    }
    
    // MARK: - Complete Payment Flow
    
    func processCompletePayment(customerName: String, amount: Double) async {
        do {
            // Step 1: Verify customer account
            currentState = .verifyingAccount
            let account = try await verifyCustomerAccount(customerName: customerName)
            
            // Step 2: Check account balance
            currentState = .checkingFunds
            let hasSufficientFunds = try await checkAccountBalance(accountId: account.accountId, amount: amount)
            
            guard hasSufficientFunds else {
                currentState = .failure("Insufficient funds in account")
                return
            }
            
            // Step 3: Check daily limits
            currentState = .checkingLimits
            let withinLimit = try await checkDailyLimit(accountId: account.accountId, amount: amount)
            
            guard withinLimit else {
                currentState = .failure("Daily payment limit exceeded")
                return
            }
            
            // Step 4: Fraud detection
            currentState = .fraudDetection
            let fraudCheck = try await performFraudDetection(accountId: account.accountId, amount: amount)
            
            guard fraudCheck.isLegitimate else {
                currentState = .failure("Transaction flagged by fraud detection: \(fraudCheck.message)")
                return
            }
            
            // Step 5: Process payment
            currentState = .processing
            let paymentResponse = try await processPayment(accountId: account.accountId, amount: amount)
            
            // Step 6: Save transaction record
            try await saveTransactionRecord(
                transactionId: paymentResponse.transactionId,
                accountId: account.accountId,
                amount: amount
            )
            
            // Success
            currentState = .success
            
        } catch {
            currentState = .failure("Payment failed: \(error.localizedDescription)")
        }
    }
    
    func resetPayment() {
        currentState = .enterAmount
        errorMessage = nil
        isLoading = false
    }
}
