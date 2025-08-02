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
    let paymentMethod: TransactionType
    let onPaymentComplete: () -> Void
    let onPaymentFailed: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                Text("Processing Payment")
                    .font(.title2)
                    .fontWeight(.bold)
                
                VStack(spacing: 8) {
                    Text("Customer: \(customerName)")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Amount: RM \(formatAmount(amount))")
                        .font(.title3)
                        .foregroundColor(.yellow)
                        .fontWeight(.semibold)
                    
                    Text("Method: \(paymentMethod.rawValue)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 30)
            
            Spacer()
            
            // Processing Steps or Result
            switch paymentService.currentState {
            case .success:
                SuccessResultView(onContinue: onPaymentComplete)
                
            case .failure(let message):
                FailureResultView(message: message, onRetry: onPaymentFailed)
                
            default:
                ProcessingStepsView(paymentService: paymentService)
            }
            
            Spacer()
        }
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
}

struct ProcessingStepsView: View {
    @ObservedObject var paymentService: PaymentService
    
    var body: some View {
        VStack(spacing: 30) {
            // Main progress indicator
            VStack(spacing: 20) {
                CircularProgressView(
                    progress: getOverallProgress(),
                    color: .yellow
                )
                .frame(width: 120, height: 120)
                
                Text(getStatusMessage())
                    .font(.headline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Processing steps
            VStack(spacing: 16) {
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
            .padding(.horizontal, 20)
        }
    }
    
    private func getOverallProgress() -> Double {
        let steps: [PaymentState] = [
            .verifyingAccount,
            .checkingFunds,
            .checkingLimits,
            .fraudDetection,
            .processing
        ]
        
        guard let currentIndex = steps.firstIndex(where: { stateMatches($0, paymentService.currentState) }) else {
            return 0.0
        }
        
        return Double(currentIndex + 1) / Double(steps.count)
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
            return "Verifying customer account..."
        case .checkingFunds:
            return "Checking account balance..."
        case .checkingLimits:
            return "Verifying daily limits..."
        case .fraudDetection:
            return "Running security checks..."
        case .processing:
            return "Finalizing payment..."
        default:
            return "Processing..."
        }
    }
}

struct SuccessResultView: View {
    let onContinue: () -> Void
    @State private var showCheckmark = false
    
    var body: some View {
        VStack(spacing: 30) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 120, height: 120)
                    .scaleEffect(showCheckmark ? 1.0 : 0.5)
                    .animation(.easeOut(duration: 0.5), value: showCheckmark)
                
                Circle()
                    .fill(Color.green)
                    .frame(width: 100, height: 100)
                    .scaleEffect(showCheckmark ? 1.0 : 0.5)
                    .animation(.easeOut(duration: 0.5).delay(0.1), value: showCheckmark)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                    .scaleEffect(showCheckmark ? 1.0 : 0.1)
                    .animation(.easeOut(duration: 0.5).delay(0.3), value: showCheckmark)
            }
            
            VStack(spacing: 12) {
                Text("Payment Successful!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                Text("Your transaction has been completed")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: onContinue) {
                Text("Continue")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.yellow)
                    .cornerRadius(25)
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            showCheckmark = true
        }
    }
}

struct FailureResultView: View {
    let message: String
    let onRetry: () -> Void
    @State private var showError = false
    
    var body: some View {
        VStack(spacing: 30) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.2))
                    .frame(width: 120, height: 120)
                    .scaleEffect(showError ? 1.0 : 0.5)
                    .animation(.easeOut(duration: 0.5), value: showError)
                
                Circle()
                    .fill(Color.red)
                    .frame(width: 100, height: 100)
                    .scaleEffect(showError ? 1.0 : 0.5)
                    .animation(.easeOut(duration: 0.5).delay(0.1), value: showError)
                
                Image(systemName: "xmark")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                    .scaleEffect(showError ? 1.0 : 0.1)
                    .animation(.easeOut(duration: 0.5).delay(0.3), value: showError)
            }
            
            VStack(spacing: 12) {
                Text("Payment Failed")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button(action: onRetry) {
                Text("Try Again")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.red)
                    .cornerRadius(25)
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            showError = true
        }
    }
}

struct ProcessingStep: View {
    let title: String
    let icon: String
    let isActive: Bool
    let isCompleted: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 40, height: 40)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                } else if isActive {
                    ProgressView()
                        .scaleEffect(0.6)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: icon)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(textColor)
            
            Spacer()
        }
    }
    
    private var backgroundColor: Color {
        if isCompleted {
            return .green
        } else if isActive {
            return .yellow
        } else {
            return .gray.opacity(0.3)
        }
    }
    
    private var textColor: Color {
        if isCompleted {
            return .green
        } else if isActive {
            return .yellow
        } else {
            return .gray
        }
    }
}
