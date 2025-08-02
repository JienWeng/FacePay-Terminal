//
//  Models.swift
//  FacePay Terminal
//
//  Created by Lai Jien Weng on 02/08/2025.
//

import Foundation

// MARK: - Payment Models
struct PaymentRequest {
    let amount: Double
    let customerName: String
    let accountId: String
}

struct Account {
    let id: String
    let customerName: String
    let balance: Double
    let dailyLimit: Double
    let dailySpent: Double
}

struct TransactionRecord {
    let id: String
    let accountId: String
    let amount: Double
    let timestamp: Date
    let type: TransactionType
    let status: TransactionStatus
}

enum TransactionType {
    case facePay
    case cardPayment
    case transfer
}

enum TransactionStatus {
    case pending
    case completed
    case failed
    case fraudDetected
}

enum PaymentState: Equatable {
    case enterAmount
    case selectPaymentMethod
    case faceScanning
    case processing
    case verifyingAccount
    case checkingFunds
    case checkingLimits
    case fraudDetection
    case success
    case failure(String)
}

// MARK: - API Response Models
struct AccountResponse: Codable {
    let accountId: String
    let customerName: String
    let balance: Double
    let dailyLimit: Double
    let dailySpent: Double
    let isActive: Bool
}

struct PaymentResponse: Codable {
    let transactionId: String
    let status: String
    let message: String
    let timestamp: String
}

struct FraudCheckResponse: Codable {
    let isLegitimate: Bool
    let riskScore: Double
    let message: String
}
