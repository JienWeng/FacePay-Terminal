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
    let onCardPaymentSelected: () -> Void
    let onBackPressed: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                HStack {
                    Button(action: onBackPressed) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.headline)
                            Text("Back")
                                .font(.headline)
                        }
                        .foregroundColor(.yellow)
                    }
                    
                    Spacer()
                }
                
                VStack(spacing: 8) {
                    Text("Select Payment Method")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Amount: RM \(formatAmount(amount))")
                        .font(.title3)
                        .foregroundColor(.yellow)
                        .fontWeight(.semibold)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 30)
            
            // Payment Methods
            VStack(spacing: 16) {
                // FacePay Option
                PaymentMethodCard(
                    icon: "faceid",
                    title: "FacePay",
                    subtitle: "Pay with facial recognition",
                    iconColor: .yellow,
                    backgroundColor: Color.yellow.opacity(0.1),
                    borderColor: Color.yellow.opacity(0.3),
                    action: onFacePaySelected
                )
                
                // Card Payment Option
                PaymentMethodCard(
                    icon: "creditcard",
                    title: "Card Payment",
                    subtitle: "Insert or tap your card",
                    iconColor: .blue,
                    backgroundColor: Color.blue.opacity(0.1),
                    borderColor: Color.blue.opacity(0.3),
                    action: onCardPaymentSelected
                )
                
                // Digital Wallet Option (Disabled)
                PaymentMethodCard(
                    icon: "iphone",
                    title: "Digital Wallet",
                    subtitle: "Pay with mobile wallet",
                    iconColor: .gray,
                    backgroundColor: Color.gray.opacity(0.1),
                    borderColor: Color.gray.opacity(0.3),
                    isDisabled: true,
                    badgeText: "Coming Soon"
                )
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Security Notice
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "lock.shield")
                        .foregroundColor(.yellow)
                        .font(.subheadline)
                    
                    Text("Secure Payment")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Text("Your payment is protected by bank-grade security")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.yellow.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
    }
    
    private func formatAmount(_ amount: String) -> String {
        if let doubleValue = Double(amount) {
            return String(format: "%.2f", doubleValue)
        }
        return amount
    }
}

struct PaymentMethodCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    let backgroundColor: Color
    let borderColor: Color
    var isDisabled: Bool = false
    var badgeText: String? = nil
    let action: (() -> Void)?
    
    @State private var isPressed = false
    
    init(icon: String, title: String, subtitle: String, iconColor: Color, backgroundColor: Color, borderColor: Color, isDisabled: Bool = false, badgeText: String? = nil, action: (() -> Void)? = nil) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.iconColor = iconColor
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.isDisabled = isDisabled
        self.badgeText = badgeText
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            guard !isDisabled, let action = action else { return }
            action()
            
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(isDisabled ? .gray : iconColor)
                    .frame(width: 44, height: 44)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(isDisabled ? .gray : .primary)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(isDisabled ? .gray : .secondary)
                }
                
                Spacer()
                
                if let badgeText = badgeText {
                    Text(badgeText)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .foregroundColor(.gray)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.headline)
                        .foregroundColor(isDisabled ? .gray : .secondary)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isDisabled ? Color.gray.opacity(0.1) : backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isDisabled ? Color.gray.opacity(0.3) : borderColor, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isDisabled)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            guard !isDisabled else { return }
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}
