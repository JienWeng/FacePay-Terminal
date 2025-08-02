//
//  PaymentSuccessView.swift
//  FacePay Terminal
//
//  Created by Lai Jien Weng on 02/08/2025.
//

import SwiftUI
import MessageUI

struct PaymentSuccessView: View {
    let amount: String
    let customerName: String
    let paymentMethod: TransactionType
    let onNewTransaction: () -> Void
    
    @StateObject private var emailService = EmailService()
    @State private var showEmailComposer = false
    @State private var customerEmail = "customer@example.com"
    @State private var showEmailInput = false
    @State private var showCheckmark = false
    @State private var showDetails = false
    
    private var receipt: Receipt {
        Receipt(
            transactionId: generateTransactionId(),
            amount: Double(amount) ?? 0,
            customerName: customerName,
            paymentMethod: paymentMethod,
            timestamp: Date(),
            merchantName: Receipt.defaultMerchant,
            merchantId: Receipt.defaultMerchantId
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Success Animation
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.yellow.opacity(0.2))
                        .frame(width: 140, height: 140)
                        .scaleEffect(showCheckmark ? 1.0 : 0.5)
                        .animation(.easeOut(duration: 0.5), value: showCheckmark)
                    
                    Circle()
                        .fill(Color.yellow)
                        .frame(width: 110, height: 110)
                        .scaleEffect(showCheckmark ? 1.0 : 0.5)
                        .animation(.easeOut(duration: 0.5).delay(0.1), value: showCheckmark)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.black)
                        .scaleEffect(showCheckmark ? 1.0 : 0.1)
                        .animation(.easeOut(duration: 0.5).delay(0.3), value: showCheckmark)
                }
                
                Text("Payment Successful!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .opacity(showDetails ? 1.0 : 0.0)
                    .animation(.easeIn(duration: 0.5).delay(0.6), value: showDetails)
            }
            
            Spacer()
            
            // Transaction Details
            VStack(spacing: 0) {
                TransactionDetailRow(
                    label: "Amount",
                    value: "RM \(formatAmount(amount))",
                    valueColor: .primary,
                    isAmount: true
                )
                
                TransactionDetailRow(
                    label: "Customer",
                    value: customerName,
                    valueColor: .primary
                )
                
                TransactionDetailRow(
                    label: "Payment Method",
                    value: paymentMethod.rawValue,
                    valueColor: .yellow
                )
                
                TransactionDetailRow(
                    label: "Transaction ID",
                    value: receipt.transactionId,
                    valueColor: .secondary
                )
                
                TransactionDetailRow(
                    label: "Date & Time",
                    value: formatCurrentDateTime(),
                    valueColor: .secondary
                )
                
                TransactionDetailRow(
                    label: "Status",
                    value: "✓ Completed",
                    valueColor: .green,
                    isLast: true
                )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(16)
            .padding(.horizontal, 20)
            .opacity(showDetails ? 1.0 : 0.0)
            .animation(.easeIn(duration: 0.5).delay(0.8), value: showDetails)
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 12) {
                // Email Receipt Button
                Button(action: {
                    if emailService.canSendEmail {
                        showEmailInput = true
                    } else {
                        // Show alert that email is not configured
                        print("Email not configured on this device")
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "envelope")
                        Text("Email Receipt")
                    }
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.yellow)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.yellow.opacity(0.1))
                    .cornerRadius(25)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.yellow, lineWidth: 1)
                    )
                }
                
                // New Transaction Button
                Button(action: onNewTransaction) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                        Text("New Transaction")
                    }
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.yellow)
                    .cornerRadius(25)
                }
            }
            .padding(.horizontal, 20)
            .opacity(showDetails ? 1.0 : 0.0)
            .animation(.easeIn(duration: 0.5).delay(1.0), value: showDetails)
            
            Spacer()
            
            // Thank You Message
            VStack(spacing: 6) {
                Text("Thank you for using FacePay Terminal")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("Your payment has been processed successfully")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .opacity(showDetails ? 1.0 : 0.0)
            .animation(.easeIn(duration: 0.5).delay(1.2), value: showDetails)
            .padding(.bottom, 30)
        }
        .onAppear {
            showCheckmark = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showDetails = true
            }
        }
        .alert("Enter Customer Email", isPresented: $showEmailInput) {
            TextField("Email address", text: $customerEmail)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            Button("Send Receipt") {
                showEmailComposer = true
            }
            
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Enter the customer's email address to send the receipt")
        }
        .sheet(isPresented: $showEmailComposer) {
            if emailService.canSendEmail {
                EmailComposerView(
                    receipt: receipt,
                    customerEmail: customerEmail,
                    isPresented: $showEmailComposer
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
    
    private func generateTransactionId() -> String {
        return "TXN-\(UUID().uuidString.prefix(8).uppercased())"
    }
    
    private func formatCurrentDateTime() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }
}

struct TransactionDetailRow: View {
    let label: String
    let value: String
    let valueColor: Color
    var isAmount: Bool = false
    var isLast: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(value)
                    .font(isAmount ? .headline : .subheadline)
                    .fontWeight(isAmount ? .bold : .medium)
                    .foregroundColor(valueColor)
            }
            .padding(.vertical, 12)
            
            if !isLast {
                Divider()
            }
        }
    }
}
