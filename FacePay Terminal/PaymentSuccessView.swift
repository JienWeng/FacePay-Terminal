//
//  PaymentSuccessView.swift
//  FacePay Terminal
//
//  Created by Lai Jien Weng on 02/08/2025.
//

import SwiftUI

struct PaymentSuccessView: View {
    let amount: String
    let customerName: String
    let onNewTransaction: () -> Void
    
    @State private var showCheckmark = false
    @State private var showDetails = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Success Animation
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 150, height: 150)
                        .scaleEffect(showCheckmark ? 1.0 : 0.5)
                        .animation(.easeOut(duration: 0.5), value: showCheckmark)
                    
                    Circle()
                        .fill(Color.green)
                        .frame(width: 120, height: 120)
                        .scaleEffect(showCheckmark ? 1.0 : 0.5)
                        .animation(.easeOut(duration: 0.5).delay(0.1), value: showCheckmark)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                        .scaleEffect(showCheckmark ? 1.0 : 0.1)
                        .animation(.easeOut(duration: 0.5).delay(0.3), value: showCheckmark)
                }
                
                Text("Payment Successful!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                    .opacity(showDetails ? 1.0 : 0.0)
                    .animation(.easeIn(duration: 0.5).delay(0.6), value: showDetails)
            }
            
            // Transaction Details
            VStack(spacing: 20) {
                TransactionDetailRow(
                    label: "Amount",
                    value: "RM \(formatAmount(amount))",
                    valueColor: .primary
                )
                
                TransactionDetailRow(
                    label: "Customer",
                    value: customerName,
                    valueColor: .primary
                )
                
                TransactionDetailRow(
                    label: "Payment Method",
                    value: "FacePay",
                    valueColor: .green
                )
                
                TransactionDetailRow(
                    label: "Transaction ID",
                    value: generateTransactionId(),
                    valueColor: .secondary
                )
                
                TransactionDetailRow(
                    label: "Date & Time",
                    value: formatCurrentDateTime(),
                    valueColor: .secondary
                )
                
                TransactionDetailRow(
                    label: "Status",
                    value: "Completed",
                    valueColor: .green
                )
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(16)
            .opacity(showDetails ? 1.0 : 0.0)
            .animation(.easeIn(duration: 0.5).delay(0.8), value: showDetails)
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 15) {
                Button(action: {
                    // In a real app, this would print a receipt
                    print("Printing receipt...")
                }) {
                    HStack {
                        Image(systemName: "printer")
                        Text("Print Receipt")
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue, lineWidth: 1)
                    )
                }
                
                Button(action: onNewTransaction) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("New Transaction")
                    }
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
            }
            .opacity(showDetails ? 1.0 : 0.0)
            .animation(.easeIn(duration: 0.5).delay(1.0), value: showDetails)
            
            // Thank You Message
            VStack(spacing: 5) {
                Text("Thank you for using FacePay")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("Your payment has been processed successfully")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .opacity(showDetails ? 1.0 : 0.0)
            .animation(.easeIn(duration: 0.5).delay(1.2), value: showDetails)
        }
        .padding()
        .onAppear {
            showCheckmark = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showDetails = true
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
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(valueColor)
        }
        .padding(.vertical, 2)
    }
}
