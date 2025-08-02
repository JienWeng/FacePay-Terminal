//
//  PaymentMethodView.swift
//  FacePay Terminal
//
//  Created by Lai Jien Weng on 02/08/2025.
//

import SwiftUI

struct PaymentMethodView: View {
    let amount: String
    let onFacePaySelected: () -> Void
    let onBackPressed: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 10) {
                HStack {
                    Button(action: onBackPressed) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.blue)
                    }
                    
                    Spacer()
                }
                
                Text("Select Payment Method")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Amount: RM \(formatAmount(amount))")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .fontWeight(.semibold)
            }
            
            Spacer()
            
            // Payment Methods
            VStack(spacing: 20) {
                // FacePay Option
                Button(action: onFacePaySelected) {
                    HStack(spacing: 20) {
                        Image(systemName: "faceid")
                            .font(.system(size: 40))
                            .foregroundColor(.green)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("FacePay")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Pay with facial recognition")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    .padding(20)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.green.opacity(0.3), lineWidth: 2)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // Card Payment Option (Disabled for demo)
                HStack(spacing: 20) {
                    Image(systemName: "creditcard")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Card Payment")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                        
                        Text("Insert or tap your card")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Text("Coming Soon")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .foregroundColor(.gray)
                }
                .padding(20)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(16)
                
                // Digital Wallet Option (Disabled for demo)
                HStack(spacing: 20) {
                    Image(systemName: "iphone")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Digital Wallet")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                        
                        Text("Pay with mobile wallet")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Text("Coming Soon")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .foregroundColor(.gray)
                }
                .padding(20)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(16)
            }
            
            Spacer()
            
            // Security Notice
            VStack(spacing: 10) {
                HStack {
                    Image(systemName: "lock.shield")
                        .foregroundColor(.green)
                    
                    Text("Secure Payment")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Text("Your payment is protected by bank-grade security")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .background(Color.green.opacity(0.1))
            .cornerRadius(12)
        }
        .padding()
    }
    
    private func formatAmount(_ amount: String) -> String {
        if let doubleValue = Double(amount) {
            return String(format: "%.2f", doubleValue)
        }
        return amount
    }
}
