//
//  AmountEntryView.swift
//  FacePay Terminal
//
//  Created by Lai Jien Weng on 02/08/2025.
//

import SwiftUI

struct AmountEntryView: View {
    @Binding var amount: String
    let onContinue: () -> Void
    
    private let keypadButtons = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        [".", "0", "⌫"]
    ]
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "creditcard.trianglebadge.exclamationmark")
                        .font(.system(size: 40))
                        .foregroundColor(.yellow)
                    
                    Text("FacePay Terminal")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                .padding(.top, 20)
                .padding(.bottom, 30)
                
                // Amount Display
                VStack(spacing: 8) {
                    Text("Enter Amount")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Text("RM")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.yellow)
                        
                        Text(formatAmount(amount))
                            .font(.system(size: 36, weight: .bold, design: .monospaced))
                            .foregroundColor(.primary)
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.yellow.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                
                // Keypad
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                    ForEach(keypadButtons.flatMap { $0 }, id: \.self) { button in
                        KeypadButton(
                            text: button,
                            action: { handleKeypadInput(button) }
                        )
                        .frame(height: min(65, geometry.size.height * 0.08))
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer(minLength: 20)
                
                // Continue Button
                Button(action: onContinue) {
                    HStack(spacing: 8) {
                        Text("Continue")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.headline)
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        isValidAmount() ? Color.yellow : Color.gray.opacity(0.3)
                    )
                    .cornerRadius(25)
                }
                .disabled(!isValidAmount())
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
    }
    
    private func handleKeypadInput(_ input: String) {
        switch input {
        case "⌫":
            if !amount.isEmpty {
                amount.removeLast()
            }
        case ".":
            if !amount.contains(".") && !amount.isEmpty {
                amount += input
            }
        default:
            // Limit to 2 decimal places
            if amount.contains(".") {
                let components = amount.split(separator: ".")
                if components.count > 1 && components[1].count >= 2 {
                    return
                }
            }
            
            // Limit total length and amount
            if amount.count < 8 {
                let newAmount = amount + input
                if let doubleValue = Double(newAmount), doubleValue <= 999999.99 {
                    amount = newAmount
                }
            }
        }
    }
    
    private func formatAmount(_ amount: String) -> String {
        if amount.isEmpty {
            return "0.00"
        }
        
        if let doubleValue = Double(amount) {
            return String(format: "%.2f", doubleValue)
        }
        
        return amount
    }
    
    private func isValidAmount() -> Bool {
        guard let doubleValue = Double(amount) else { return false }
        return doubleValue > 0 && doubleValue <= 999999.99
    }
}

struct KeypadButton: View {
    let text: String
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            action()
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }) {
            Text(text)
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isPressed ? Color.yellow.opacity(0.3) : Color.gray.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.yellow.opacity(0.2), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}
