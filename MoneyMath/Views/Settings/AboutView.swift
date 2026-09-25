//
//  AboutView.swift
//  AdsDemoSwiftUI
//
//  Created by Adverge on 21/08/25.
//

import SwiftUI
import Charts

struct AboutView: View {
    // Example Data for Charts
    struct ChartData: Identifiable {
        let id = UUID()
        let year: Int
        let value: Double
    }
    
    private let siData = [
        ChartData(year: 1, value: 1000),
        ChartData(year: 2, value: 2000),
        ChartData(year: 3, value: 3000),
        ChartData(year: 4, value: 4000)
    ]
    
    private let ciData = [
        ChartData(year: 1, value: 1050),
        ChartData(year: 2, value: 1102.5),
        ChartData(year: 3, value: 1157.6),
        ChartData(year: 4, value: 1215.5)
    ]
    
    private let emiData = [
        ChartData(year: 1, value: 5000),
        ChartData(year: 2, value: 10000),
        ChartData(year: 3, value: 15000),
        ChartData(year: 4, value: 20000)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // App Icon / Symbol
                Image(systemName: "banknote.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.green)
                    .padding(.top, 30)
                
                // Title
                Text("Interest & EMI Calculator")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Divider().padding(.vertical, 10)
                
                // Description
                Text("This app helps you calculate **Simple Interest (SI)**, **Compound Interest (CI)**, and **Equated Monthly Instalment (EMI)**. Charts help visualize how your money grows or repayments progress.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // MARK: SI Section
                sectionHeader("Simple Interest (SI)", symbol: "chart.line.uptrend.xyaxis")
                Text("Simple Interest is the interest calculated only on the principal amount over a period of time. It does not compound, meaning interest is not calculated on interest.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Chart(siData) {
                    LineMark(x: .value("Year", $0.year),
                             y: .value("Amount", $0.value))
                    PointMark(x: .value("Year", $0.year),
                              y: .value("Amount", $0.value))
                }
                .frame(height: 200)
                .padding(.bottom)
                
                // MARK: CI Section
                sectionHeader("Compound Interest (CI)", symbol: "chart.bar.xaxis")
                Text("Compound Interest is interest calculated on the principal and also on any accumulated interest from previous periods. This allows your money to grow faster.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Chart(ciData) {
                    BarMark(x: .value("Year", $0.year),
                            y: .value("Amount", $0.value))
                }
                .frame(height: 200)
                .padding(.bottom)
                
                // MARK: EMI Section
                sectionHeader("Equated Monthly Instalment (EMI)", symbol: "calendar")
                Text("EMI is the fixed monthly payment you make to repay a loan over a specified period. Each EMI consists of both principal and interest.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Chart(emiData) {
                    LineMark(x: .value("Month", $0.year),
                             y: .value("Repayment", $0.value))
                    AreaMark(x: .value("Month", $0.year),
                             y: .value("Repayment", $0.value))
                        .foregroundStyle(.green.opacity(0.3))
                }
                .frame(height: 200)
                .padding(.bottom)
                
                Divider().padding(.vertical, 10)
                
                // Credits
                VStack(spacing: 6) {
                    Label("Developed by Adverge", systemImage: "person.fill")
                        .font(.subheadline)
                    
                    Text("Version \(appVersion)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("© \(currentYear) Adverge. All rights reserved.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: Section Header
    private func sectionHeader(_ text: String, symbol: String) -> some View {
        Label(text, systemImage: symbol)
            .font(.headline)
            .foregroundColor(.green)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 8)
    }
    
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
    
    private var currentYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: Date())
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
