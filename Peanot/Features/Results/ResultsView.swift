//
//  ResultsView.swift
//  Peanot
//
//  Created by Steven Thienvanich on 10/24/26.
//

//import SwiftUI
//
//struct Verdict {
//    let symbol: String
//    let foreground: Color
//    let label: String
//    let headline: String
//}
//
//struct ResultsView: View {
//    let barcode: String
//    let product: Product
//
//    @Environment(\.dismiss) private var dismiss
//    @State private var selectedAllergens = AllergenPreferences.load()
//    @State private var isSaved = false
//    
//    private var verdict: Verdict {
//        Verdict(
//            symbol: "checkmark",
//            foreground: .green,
//            label: "Safe",
//            headline: "No allergens detected"
//        )
//    }
//    
//    var body: some View {
//        VStack(alignment: .leading) {
//            verdictBanner
//            productHeader
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
//    }
//
//    // MARK: - Banner
//
//    private var verdictBanner: some View {
//        HStack(alignment: .top, spacing: PeanotSpacing.md) {
//            Circle()
//                .fill(.white)
//                .frame(width: 56, height: 56)
//                .overlay {
//                    Image(systemName: verdict.symbol)
//                        .font(.system(size: 22, weight: .bold))
//                        .foregroundStyle(verdict.foreground)
//                }
//
//            VStack(alignment: .leading, spacing: PeanotSpacing.xs) {
//                Text(verdict.label)
//                    .font(PeanotTypography.largeTitle)
//
//                Text(verdict.headline)
//                    .font(PeanotTypography.headline)
//                    .fixedSize(horizontal: false, vertical: true)
//            }
//            .foregroundStyle(.white)
//        }
//        .padding(PeanotSpacing.lg)
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .background(verdict.foreground)
//    }
//    
//    private var productHeader: some View {
//        HStack {
//            if let imageURL = product.image, !imageURL.absoluteString.isEmpty {
//                AsyncImage(url: product.image) { image in
//                    image
//                        .resizable()
//                        .scaledToFit()
//                } placeholder: {
//                    ProgressView()
//                }
//                .frame(width: 100, height: 100)
//            }
//
//            VStack(alignment: .leading) {
//                Text(product.label)
//                    .font(.headline)
//
//                Text(product.brand ?? "Unknown brand")
//                    .font(.subheadline)
//            }
//        }
//        .padding()
//    }
//    
//    private var analysisSection: some View {
//        VStack(alignment: .leading, spacing: PeanotSpacing.md) {
//            
//        }
//        .padding()
//    }
//    
//    
//}
//
//#Preview {
//    ResultsView(
//        barcode: "012345678905",
//        product: Product(
//            foodId: "food_preview",
//            label: "Honey Oat Crunch Bar",
//            knownAs: nil,
//            brand: "Fieldline",
//            category: "Packaged foods",
//            categoryLabel: "food",
//            foodContentsLabel: "Whole grain oats, honey, peanut butter (roasted peanuts, salt), "
//                + "brown rice syrup, peanut flour, sunflower oil, sea salt, natural flavor. "
//                + "May contain almonds.",
//            image:  URL(string: "https://www.fritolay.com/sites/fritolay.com/files/2022-02/Baked_2021_Lays_ORIG_6.25oz_Render.png"),
//            nutrients: ProductNutrients(
//                calories: 190, fat: 8, saturatedFat: 1, transFat: 0,
//                carbohydrates: 26, fiber: 3, sugar: 11, addedSugar: 9,
//                protein: 5, cholesterol: 0, sodium: 130, calcium: nil,
//                potassium: nil, iron: nil, vitaminD: nil
//            ),
//            servingSizes: [
//                ProductServingSize(uri: "serving", label: "bar", quantity: 1)
//            ],
//            servingsPerContainer: 6
//        )
//    )
//}

import SwiftUI
import SwiftData

struct Verdict {
    let symbol: String
    let foreground: Color
    let label: String
    let headline: String
}

struct ResultsView: View {
    let barcode: String
    let product: Product

    private let cachedScan: RecentScan?
    private let isScannedLabel: Bool

    @Environment(\.modelContext) private var context

    @State private var selectedAllergens = AllergenPreferences.load()
    @State private var analysis: AllergenAnalysis?
    @State private var isAnalyzing = false
    @State private var analysisError: String?

    @State private var editableIngredients: String
    @State private var isEditingIngredients = false

    private let analyzeService = AnalyzeService()

    init(barcode: String, product: Product) {
        self.barcode = barcode
        self.product = product
        self.cachedScan = nil
        self.isScannedLabel = false
        self._editableIngredients = State(
            initialValue: product.foodContentsLabel ?? ""
        )
    }

    init(recentScan: RecentScan) {
        self.barcode = recentScan.barcode
        self.product = recentScan.cachedProduct
        self.cachedScan = recentScan
        self.isScannedLabel = false
        self._editableIngredients = State(
            initialValue: recentScan.ingredients ?? ""
        )
    }

    init(ingredients: String) {
        self.barcode = ""
        self.product = Product.scannedLabel(ingredients: ingredients)
        self.cachedScan = nil
        self.isScannedLabel = true
        self._editableIngredients = State(initialValue: ingredients)
    }

    private var ingredientText: String? {
        isScannedLabel ? editableIngredients : product.foodContentsLabel
    }

    private var verdict: Verdict {
        guard let analysis else {
            return Verdict(
                symbol: "questionmark",
                foreground: .gray,
                label: "Not Verified",
                headline: "Allergen status is unknown"
            )
        }

        switch analysis.verdict {
        case .avoid:
            return Verdict(
                symbol: "xmark",
                foreground: .red,
                label: "Avoid",
                headline: "Selected allergen detected"
            )

        case .caution:
            return Verdict(
                symbol: "exclamationmark.triangle",
                foreground: .orange,
                label: "Caution",
                headline: "Possible allergen risk"
            )

        case .noListedAllergens:
            return Verdict(
                symbol: "checkmark",
                foreground: .green,
                label: "No Match Found",
                headline: "No selected allergens identified"
            )
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                verdictBanner
                productHeader
                analysisSection
                ingredientsSection
            }
        }
        .task(id: barcode) {
            await analyzeProduct()
        }
        .animation(.default, value: isEditingIngredients)
    }

    // MARK: - Banner

    private var verdictBanner: some View {
        HStack(alignment: .top, spacing: PeanotSpacing.md) {
            Circle()
                .fill(.white)
                .frame(width: 56, height: 56)
                .overlay {
                    Image(systemName: verdict.symbol)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(verdict.foreground)
                }

            VStack(alignment: .leading, spacing: PeanotSpacing.xs) {
                Text(verdict.label)
                    .font(PeanotTypography.largeTitle)

                Text(verdict.headline)
                    .font(PeanotTypography.headline)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .foregroundStyle(.white)
        }
        .padding(PeanotSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(verdict.foreground)
    }

    // MARK: - Product Header

    @ViewBuilder
    private var productHeader: some View {
        if isScannedLabel {
            HStack(spacing: PeanotSpacing.md) {
                Image(systemName: "text.viewfinder")
                    .font(.system(size: 28))
                    .foregroundStyle(PeanotColors.primary)
                    .frame(width: 56, height: 56)
                    .background(PeanotColors.selected, in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text("Scanned label")
                        .font(.headline)

                    Text("Read from the ingredient list")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        } else {
            standardProductHeader
        }
    }

    private var standardProductHeader: some View {
        HStack(spacing: PeanotSpacing.md) {
            if let imageURL = product.image {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 100, height: 100)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(product.label)
                    .font(.headline)

                Text(product.brand ?? "Unknown brand")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }

    // MARK: - Analysis Section

    private var analysisSection: some View {
        VStack(alignment: .leading, spacing: PeanotSpacing.md) {
            Text("Allergen Analysis")
                .font(.title2)
                .bold()

            if isAnalyzing {
                HStack(spacing: 12) {
                    ProgressView()
                    Text("Analyzing ingredients...")
                        .foregroundStyle(.secondary)
                }
            } else if let analysis {
                Text(analysis.explanation)
                    .font(.body)

                if !analysis.detectedAllergens.isEmpty {
                    Text("Detected Allergens")
                        .font(.headline)

                    ForEach(analysis.detectedAllergens, id: \.self) { allergen in
                        Label(
                            allergen,
                            systemImage: "exclamationmark.triangle.fill"
                        )
                        .foregroundStyle(.orange)
                    }
                }

                Text("AI analysis cannot guarantee food safety. Always check the product's current packaging and allergen warnings.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

            } else if let analysisError {
                Text(analysisError)
                    .foregroundStyle(.red)

                Button("Try Again") {
                    Task {
                        await analyzeProduct()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
    
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: PeanotSpacing.md) {
            HStack {
                Text("INGREDIENTS")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)

                if isScannedLabel {
                    Spacer()

                    Button(isEditingIngredients ? "Done" : "Edit") {
                        isEditingIngredients.toggle()

                        if !isEditingIngredients {
                            Task { await analyzeProduct() }
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(PeanotColors.primary)
                }
            }

            if isScannedLabel && isEditingIngredients {
                TextEditor(text: $editableIngredients)
                    .font(.subheadline)
                    .frame(minHeight: 160)
                    .scrollContentBackground(.hidden)
                    .padding(PeanotSpacing.sm)
                    .background(PeanotColors.surface, in: RoundedRectangle(cornerRadius: PeanotRadius.small))
                    .overlay(
                        RoundedRectangle(cornerRadius: PeanotRadius.small)
                            .stroke(PeanotColors.border, lineWidth: 1)
                    )

                Text("OCR can misread small print. Fix anything that looks wrong before relying on the verdict.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

            } else if let ingredients = ingredientText,
                      !ingredients.isEmpty {

                highlightedIngredients(
                    ingredients,
                    highlights: analysis?.highlights ?? []
                )
                .font(.subheadline)
                .lineSpacing(5)

            } else {
                Text("Ingredient information unavailable.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
    
    private func highlightedIngredients(_ ingredients: String, highlights: [IngredientHighlight]) -> Text {
        let source = ingredients as NSString
        var ranges: [(range: NSRange, type: HighlightType)] = []

        for highlight in highlights {
            guard !highlight.phrase.isEmpty else { continue }

            let matches = source.range(
                of: highlight.phrase,
                options: [.caseInsensitive]
            )

            if matches.location != NSNotFound {
                ranges.append((
                    range: matches,
                    type: highlight.type
                ))
            }
        }

        ranges.sort {
            $0.range.location < $1.range.location
        }

        var result = Text("")
        var position = 0

        for item in ranges {
            guard item.range.location >= position else {
                continue
            }

            if item.range.location > position {
                let normalRange = NSRange(
                    location: position,
                    length: item.range.location - position
                )

                result = result + Text(
                    source.substring(with: normalRange)
                )
            }

            let phrase = source.substring(with: item.range)

            let color: Color = item.type == .confirmed
                ? .red
                : .orange

            result = result + Text(phrase)
                .bold()
                .foregroundColor(color)

            position = NSMaxRange(item.range)
        }

        if position < source.length {
            result = result + Text(
                source.substring(from: position)
            )
        }

        return result
    }


    // MARK: - Analyze Product

    @MainActor
    private func analyzeProduct() async {
        guard !isAnalyzing else { return }

        analysis = nil
        analysisError = nil

        if let cachedScan, cachedScan.matches(allergens: selectedAllergens) {
            analysis = cachedScan.analysis
            return
        }

        guard let ingredients = ingredientText,
              !ingredients.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            analysisError = isScannedLabel
                ? "No ingredient text was captured. Scan the label again."
                : "Ingredient information is unavailable. Allergen status cannot be determined."
            return
        }

        guard !selectedAllergens.isEmpty else {
            analysisError = "Please select allergens to analyze."
            return
        }

        isAnalyzing = true
        defer { isAnalyzing = false }

        do {
            let result = try await analyzeService.analyze(
                ingredients: ingredients,
                allergens: Array(selectedAllergens)
            )

            analysis = result

            if !isScannedLabel {
                ScanHistory.record(
                    barcode: barcode,
                    product: product,
                    analysis: result,
                    analyzedAllergens: selectedAllergens,
                    in: context
                )
            }
        } catch {
            analysisError = "Analysis failed: \(error.localizedDescription)"
        }
    }
}
