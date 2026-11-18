//
//  SearchView.swift
//  Peanot
//
//  Created by Steven Thienvanich on 10/24/26.
//

import SwiftUI

struct SearchView: View {
    @State private var query = ""
    @State private var results: [SearchResult] = []
    @State private var phase: Phase = .idle
    @State private var selectedAllergens = AllergenPreferences.load()
    @State private var searchTask: Task<Void, Never>?
    @State private var showScanner = false

    private let productSearch = ProductSearch()
    private let debounce = Duration.milliseconds(400)

    private enum Phase: Equatable {
        case idle
        case searching
        case loaded
        case failed(String)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header

                Group {
                    switch phase {
                        case .idle:
                            idleState
                        case .searching:
                            loadingState
                        case .failed(let message):
                            errorState(message)
                        case .loaded:
                            if results.isEmpty {
                                noResultsState
                            } else {
                                resultList
                            }
                    }
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .top
                )
            }
            .peanotBackground()
            .navigationDestination(isPresented: $showScanner) {
                ScanView()
            }
        }
        .toolbarVisibility(.hidden, for: .navigationBar)
        .onAppear {
            let current = AllergenPreferences.load()
            guard current != selectedAllergens else { return }

            selectedAllergens = current
            results = results.map { $0.rescreened(against: current) }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: PeanotSpacing.md) {
            Text("Search")
                .font(PeanotTypography.largeTitle)
                .foregroundStyle(PeanotColors.text)

            searchField

            if phase == .loaded, !results.isEmpty {
                resultSummary
            }
        }
        .padding(.horizontal, PeanotSpacing.lg)
        .padding(.top, PeanotSpacing.lg)
        .padding(.bottom, PeanotSpacing.md)
    }

    private var searchField: some View {
        HStack(spacing: PeanotSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(PeanotColors.primary)

            TextField("Search products", text: $query)
                .font(PeanotTypography.body)
                .foregroundStyle(PeanotColors.text)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .submitLabel(.search)
                .onSubmit { scheduleSearch(immediately: true) }

            if !query.isEmpty {
                Button {
                    query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(PeanotColors.text.opacity(0.35))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
            }

            Button {
                showScanner = true
            } label: {
                Image(systemName: "barcode.viewfinder")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(PeanotColors.primary)
                    .padding(6)
                    .background(PeanotColors.selected)
                    .clipShape(RoundedRectangle(cornerRadius: PeanotRadius.small))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Scan a barcode instead")
        }
        .padding(.horizontal, PeanotSpacing.md)
        .padding(.vertical, 10)
        .background(PeanotColors.surface)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(PeanotColors.primary, lineWidth: 1.5)
        )
        .onChange(of: query) { scheduleSearch() }
    }

    private var resultSummary: some View {
        let safe = results.filter { $0.verdict == .noListedAllergens }.count

        return Text(summaryText(total: results.count, safe: safe))
            .font(PeanotTypography.caption)
            .foregroundStyle(PeanotColors.text.opacity(0.6))
    }

    private func summaryText(total: Int, safe: Int) -> String {
        let products = "\(total) product\(total == 1 ? "" : "s")"

        guard !selectedAllergens.isEmpty else { return products }

        return "\(products) · \(safe) with no match for your profile"
    }

    // MARK: - Results

    private var resultList: some View {
        ScrollView {
            LazyVStack(spacing: PeanotSpacing.sm) {
                ForEach(results) { result in
                    NavigationLink {
                        ResultsView(
                            barcode: result.product.foodId,
                            product: result.product
                        )
                    } label: {
                        SearchResultRow(result: result)
                    }
                    .buttonStyle(.plain)
                }

                disclaimer
            }
            .padding(.horizontal, PeanotSpacing.lg)
            .padding(.bottom, PeanotSpacing.lg)
        }
        .scrollDismissesKeyboard(.immediately)
    }

    private var disclaimer: some View {
        Text("Badges are a quick label check. Open a product for the full ingredient analysis.")
            .font(PeanotTypography.caption)
            .foregroundStyle(PeanotColors.text.opacity(0.5))
            .multilineTextAlignment(.center)
            .padding(.horizontal, PeanotSpacing.md)
            .padding(.top, PeanotSpacing.sm)
    }

    // MARK: - States

    private var idleState: some View {
        VStack(spacing: PeanotSpacing.sm) {
            Text("Search by product or brand")
                .font(PeanotTypography.headline)
                .foregroundStyle(PeanotColors.text)

            Text("Results are checked against your allergy profile.")
                .font(PeanotTypography.body)
                .foregroundStyle(PeanotColors.text.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .padding(PeanotSpacing.xl)
    }

    private var loadingState: some View {
        ProgressView()
            .controlSize(.large)
            .tint(PeanotColors.primary)
    }

    private var noResultsState: some View {
        VStack(spacing: PeanotSpacing.sm) {
            Image(systemName: "shippingbox")
                .font(.system(size: 32))
                .foregroundStyle(PeanotColors.primary.opacity(0.5))

            Text("No products found")
                .font(PeanotTypography.headline)
                .foregroundStyle(PeanotColors.text)

            Text("Try a different spelling, or scan the barcode instead.")
                .font(PeanotTypography.body)
                .foregroundStyle(PeanotColors.text.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .padding(PeanotSpacing.xl)
    }

    private func errorState(_ message: String) -> some View {
        VStack(spacing: PeanotSpacing.md) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 32))
                .foregroundStyle(PeanotColors.cautionText)

            Text(message)
                .font(PeanotTypography.body)
                .foregroundStyle(PeanotColors.text.opacity(0.7))
                .multilineTextAlignment(.center)

            Button("Try again") { scheduleSearch(immediately: true) }
                .font(PeanotTypography.headline)
                .foregroundStyle(PeanotColors.primary)
        }
        .padding(PeanotSpacing.xl)
    }

    // MARK: - Searching

    private func scheduleSearch(immediately: Bool = false) {
        searchTask?.cancel()

        let term = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard term.count >= 2 else {
            results = []
            phase = .idle
            return
        }

        phase = .searching

        searchTask = Task {
            if !immediately {
                try? await Task.sleep(for: debounce)
                guard !Task.isCancelled else { return }
            }

            await runSearch(term: term)
        }
    }

    private func runSearch(term: String) async {
        do {
            let products = try await productSearch.searchProducts(matching: term)

            guard !Task.isCancelled else { return }

            results = products.map {
                SearchResult(product: $0, allergens: selectedAllergens)
            }
            phase = .loaded

        } catch is CancellationError {
            return
        } catch {
            guard !Task.isCancelled else { return }

            phase = .failed("Couldn't reach the product database.")
        }
    }
}

// MARK: - Result model

struct SearchResult: Identifiable {
    let product: Product
    let screening: AllergenPrescreen.Result
    let id = UUID()

    init(product: Product, allergens: Set<String>) {
        self.product = product
        self.screening = AllergenPrescreen.screen(
            ingredients: product.foodContentsLabel,
            against: allergens
        )
    }

    private init(product: Product, screening: AllergenPrescreen.Result) {
        self.product = product
        self.screening = screening
    }

    var verdict: AllergenVerdict { screening.verdict }

    func detail(profileCount: Int) -> String {
        let matched = screening.matchedAllergens

        switch screening {
        case .clear:
            return profileCount == 0
                ? "No allergy profile set"
                : "None of your \(profileCount) allergens found"

        case .caution where matched.isEmpty:
            return "Ingredients unavailable"

        case .caution:
            return "May contain \(matched.joined(separator: ", ").lowercased())"

        case .avoid:
            return "Contains \(matched.joined(separator: ", ").lowercased())"
        }
    }

    func rescreened(against allergens: Set<String>) -> SearchResult {
        SearchResult(product: product, allergens: allergens)
    }
}

// MARK: - Row

struct SearchResultRow: View {
    let result: SearchResult

    @State private var profileCount = AllergenPreferences.load().count

    var body: some View {
        HStack(spacing: PeanotSpacing.md) {
            thumbnail

            VStack(alignment: .leading, spacing: 2) {
                Text(result.product.label)
                    .font(PeanotTypography.headline)
                    .foregroundStyle(PeanotColors.text)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(result.product.brand ?? "Unknown brand")
                    .font(PeanotTypography.caption)
                    .foregroundStyle(PeanotColors.text.opacity(0.6))
                    .lineLimit(1)

                Text(result.detail(profileCount: profileCount))
                    .font(PeanotTypography.caption)
                    .foregroundStyle(detailColor)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }

            Spacer(minLength: PeanotSpacing.sm)

            VerdictBadge(verdict: result.verdict)
        }
        .padding(PeanotSpacing.md)
        .background(PeanotColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: PeanotRadius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: PeanotRadius.medium)
                .stroke(PeanotColors.border, lineWidth: 1)
        )
    }

    private var detailColor: Color {
        switch result.verdict {
        case .avoid: PeanotColors.avoidText
        case .caution: PeanotColors.cautionText
        case .noListedAllergens: PeanotColors.text.opacity(0.6)
        }
    }

    private var thumbnail: some View {
        RoundedRectangle(cornerRadius: PeanotRadius.small)
            .fill(PeanotColors.selected)
            .frame(width: 48, height: 48)
            .overlay {
                if let imageURL = result.product.image {
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ProgressView()
                            .controlSize(.small)
                    }
                    .frame(width: 48, height: 48)
                    .clipShape(
                        RoundedRectangle(cornerRadius: PeanotRadius.small)
                    )
                } else {
                    Image(systemName: "shippingbox")
                        .foregroundStyle(PeanotColors.primary.opacity(0.6))
                }
            }
    }
}

#Preview {
    SearchView()
}
