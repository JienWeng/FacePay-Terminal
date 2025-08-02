//
//  PaymentProcessingView.swift
//  FacePay Terminal
//
//  Created by Lai Jien Weng on 02/08/2025.
//

import SwiftUI

struct PaymentProcessingView: View {
    @ObservedObject var paymentService: PaymentService
    let amount: String
    let customerName: String
    let onPaymentComplete: () -> Void
    let onPaymentFailed: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            // Header
            Text("Processing Payment")
                .font(.title)
                .fontWeight(.bold)
            
            // Customer Info
            VStack(spacing: 10) {
                Text("Customer: \(customerName)")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Amount: RM \(formatAmount(amount))")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .fontWeight(.semibold)
            }
            
            Spacer()
            
            // Processing Steps
            VStack(spacing: 30) {
                ProcessingStep(
                    title: "Verifying Account",
                    icon: "person.crop.circle.badge.checkmark",
                    isActive: paymentService.currentState == .verifyingAccount,
                    isCompleted: isStepCompleted(.verifyingAccount)
                )
                
                ProcessingStep(
                    title: "Checking Funds",
                    icon: "dollarsign.circle",
                    isActive: paymentService.currentState == .checkingFunds,
                    isCompleted: isStepCompleted(.checkingFunds)
                )
                
                ProcessingStep(
                    title: "Checking Limits",
                    icon: "shield.checkered",
                    isActive: paymentService.currentState == .checkingLimits,
                    isCompleted: isStepCompleted(.checkingLimits)
                )
                
                ProcessingStep(
                    title: "Fraud Detection",
                    icon: "eye.circle",
                    isActive: paymentService.currentState == .fraudDetection,
                    isCompleted: isStepCompleted(.fraudDetection)
                )
                
                ProcessingStep(
                    title: "Processing Payment",
                    icon: "creditcard.circle",
                    isActive: paymentService.currentState == .processing,
                    isCompleted: isStepCompleted(.processing)
                )
            }
            
            Spacer()
            
            // Status Messages
            switch paymentService.currentState {
            case .success:
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                    
                    Text("Payment Successful!")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Button(action: onPaymentComplete) {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(12)
                    }
                }
                
            case .failure(let message):
                VStack(spacing: 20) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.red)
                    
                    Text("Payment Failed")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                    
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button(action: onPaymentFailed) {
                        Text("Try Again")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(12)
                    }
                }
                
            default:
                VStack(spacing: 15) {
                    ProgressView()
                        .scaleEffect(1.5)
                    
                    Text(getStatusMessage())
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding()
        .onAppear {
            Task {
                await paymentService.processCompletePayment(
                    customerName: customerName,
                    amount: Double(amount) ?? 0
                )
            }
        }
    }
    
    private func formatAmount(_ amount: String) -> String {
        if let doubleValue = Double(amount) {
            return String(format: "%.2f", doubleValue)
        }
        return amount
    }
    
    private func isStepCompleted(_ step: PaymentState) -> Bool {
        let steps: [PaymentState] = [
            .verifyingAccount,
            .checkingFunds,
            .checkingLimits,
            .fraudDetection,
            .processing
        ]
        
        guard let currentIndex = steps.firstIndex(where: { stateMatches($0, paymentService.currentState) }),
              let stepIndex = steps.firstIndex(where: { stateMatches($0, step) }) else {
            return false
        }
        
        return currentIndex > stepIndex || paymentService.currentState == .success
    }
    
    private func stateMatches(_ state1: PaymentState, _ state2: PaymentState) -> Bool {
        switch (state1, state2) {
        case (.verifyingAccount, .verifyingAccount),
             (.checkingFunds, .checkingFunds),
             (.checkingLimits, .checkingLimits),
             (.fraudDetection, .fraudDetection),
             (.processing, .processing):
            return true
        default:
            return false
        }
    }
    
    private func getStatusMessage() -> String {
        switch paymentService.currentState {
        case .verifyingAccount:
            return "Verifying customer account details..."
        case .checkingFunds:
            return "Checking account balance..."
        case .checkingLimits:
            return "Verifying daily payment limits..."
        case .fraudDetection:
            return "Running fraud detection checks..."
        case .processing:
            return "Processing your payment..."
        default:
            return "Please wait..."
        }
    }
}

struct ProcessingStep: View {
    let title: String
    let icon: String
    let isActive: Bool
    let isCompleted: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 50, height: 50)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                } else if isActive {
                    ProgressView()
                        .scaleEffect(0.8)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(.gray)
                }
            }
            
            Text(title)
                .font(.headline)
                .foregroundColor(textColor)
            
            Spacer()
        }
        .padding(.horizontal)
    }
    
    private var backgroundColor: Color {
        if isCompleted {
            return .green
        } else if isActive {
            return .blue
        } else {
            return .gray.opacity(0.3)
        }
    }
    
    private var textColor: Color {
        if isCompleted || isActive {
            return .primary
        } else {
            return .gray
        }
    }
}
