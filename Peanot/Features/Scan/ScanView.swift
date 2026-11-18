//
//  ScanView.swift
//  Peanot
//
//  Created by Steven Thienvanich on 10/24/26.
//

import SwiftUI
import VisionKit

struct ScanView: View {
    @State private var mode: ScanMode = .barcode

    // Barcode flow
    @State private var scannedCode = "No code scanned yet"
    @State private var isLookingUpProduct = false
    @State private var lookupError: String?
    @State private var product: Product?
    @State private var showResults = false

    // Ingredient (OCR) flow
    @State private var liveTextItems: [String] = []
    @State private var capturedIngredients = ""
    @State private var showIngredientResults = false

    private var isScannerAvailable: Bool {
        DataScannerViewController.isSupported &&
        DataScannerViewController.isAvailable
    }

    private var liveText: String {
        liveTextItems.joined(separator: " ")
    }

    var body: some View {
        VStack(spacing: PeanotSpacing.md) {
            modePicker

            if isScannerAvailable {
                DataScannerView(
                    mode: mode,
                    recognizedText: $scannedCode,
                    recognizedTextItems: $liveTextItems
                )
                .id(mode)
                .frame(maxWidth: .infinity)
                .frame(height: 400)
                .clipShape(RoundedRectangle(cornerRadius: PeanotRadius.medium))
            } else {
                ContentUnavailableView(
                    "Scanner Unavailable",
                    systemImage: "camera.badge.clock",
                    description: Text("Camera access is restricted or device is unsupported.")
                )
                .frame(height: 400)
            }

            switch mode {
                case .barcode: barcodeFooter
                case .text: ingredientFooter
            }

            Spacer(minLength: 0)
        }
        .padding(PeanotSpacing.lg)
        .peanotBackground()
        .onChange(of: mode) { resetForModeChange() }
        .onChange(of: scannedCode) { lookUpScannedProduct() }
        .navigationDestination(isPresented: $showResults) {
            if let product {
                ResultsView(
                    barcode: scannedCode,
                    product: product
                )
            }
        }
        .navigationDestination(isPresented: $showIngredientResults) {
            ResultsView(ingredients: capturedIngredients)
        }
    }

    // MARK: - Mode Picker

    private var modePicker: some View {
        HStack(spacing: PeanotSpacing.xs) {
            ForEach(ScanMode.allCases, id: \.self) { option in
                let isSelected = option == mode

                Button {
                    guard !isSelected else { return }
                    mode = option
                } label: {
                    HStack(spacing: PeanotSpacing.sm) {
                        Image(systemName: option.symbol)
                        Text(option.title)
                    }
                    .font(PeanotTypography.headline)
                    .foregroundStyle(
                        isSelected ? PeanotColors.surface : PeanotColors.primary
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, PeanotSpacing.sm + 2)
                    .background(
                        isSelected ? PeanotColors.primary : .clear,
                        in: Capsule()
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(PeanotSpacing.xs)
        .background(PeanotColors.selected, in: Capsule())
    }

    // MARK: - Barcode Footer

    private var barcodeFooter: some View {
        VStack(spacing: PeanotSpacing.sm) {
            if isLookingUpProduct {
                HStack(spacing: PeanotSpacing.sm) {
                    ProgressView()
                    Text("Looking up product...")
                        .font(PeanotTypography.body)
                        .foregroundStyle(PeanotColors.text.opacity(0.7))
                }
            } else if let lookupError {
                Text(lookupError)
                    .font(PeanotTypography.body)
                    .foregroundStyle(PeanotColors.avoidText)
                    .multilineTextAlignment(.center)

                Text("Try the Ingredients tab to read the label instead.")
                    .font(PeanotTypography.caption)
                    .foregroundStyle(PeanotColors.text.opacity(0.7))
                    .multilineTextAlignment(.center)
            } else {
                Text("Point the camera at a product barcode.")
                    .font(PeanotTypography.body)
                    .foregroundStyle(PeanotColors.text.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Ingredient Footer

    private var ingredientFooter: some View {
        VStack(alignment: .leading, spacing: PeanotSpacing.sm) {
            Text("INGREDIENTS IN VIEW")
                .font(PeanotTypography.caption)
                .tracking(0.8)
                .foregroundStyle(PeanotColors.text.opacity(0.7))

            ScrollView {
                Text(liveText.isEmpty
                     ? "Hold the camera over the ingredient list."
                     : liveText)
                    .font(PeanotTypography.caption)
                    .foregroundStyle(
                        liveText.isEmpty
                        ? PeanotColors.text.opacity(0.5)
                        : PeanotColors.text
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 72)

            Button {
                capturedIngredients = liveText
                showIngredientResults = true
            } label: {
                Text("Use this text")
            }
            .buttonStyle(PeanotPrimaryButtonStyle())
            .disabled(liveText.isEmpty)
            .opacity(liveText.isEmpty ? 0.5 : 1)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Actions
    
    private func resetForModeChange() {
        scannedCode = "No code scanned yet"
        product = nil
        lookupError = nil
        isLookingUpProduct = false
        liveTextItems = []
        capturedIngredients = ""
    }

    private func lookUpScannedProduct() {
        guard scannedCode != "No code scanned yet" else { return }

        let barcode = scannedCode
        lookupError = nil
        isLookingUpProduct = true

        Task {
            defer { isLookingUpProduct = false }

            do {
                let data = try await ProductSearch().fetchProduct(
                    barcode: barcode
                )

                let response = try JSONDecoder().decode(
                    ProductResponse.self,
                    from: data
                )

                guard let fetchedProduct = response.hints.first?.food else {
                    lookupError = "No product found for this barcode."
                    return
                }

                product = fetchedProduct
                showResults = true

            } catch {
                print("Product lookup failed: \(error)")
                lookupError = "Product lookup failed. Please try again."
            }
        }
    }
}
