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

enum TransactionType: String, CaseIterable {
    case facePay = "FacePay"
    case cardPayment = "Card Payment"
    case transfer = "Bank Transfer"
}

enum TransactionStatus: String {
    case pending = "Pending"
    case completed = "Completed"
    case failed = "Failed"
    case fraudDetected = "Fraud Detected"
}

enum PaymentState: Equatable {
    case enterAmount
    case selectPaymentMethod
    case faceScanning
    case cardPayment
    case processing
    case verifyingAccount
    case checkingFunds
    case checkingLimits
    case fraudDetection
    case success
    case failure(String)
}

// MARK: - Receipt Model
struct Receipt {
    let transactionId: String
    let amount: Double
    let customerName: String
    let paymentMethod: TransactionType
    let timestamp: Date
    let merchantName: String
    let merchantId: String
    
    static let defaultMerchant = "FacePay Terminal"
    static let defaultMerchantId = "FPT001"
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
