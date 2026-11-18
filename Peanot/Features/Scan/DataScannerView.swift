//
//  DataScannerView.swift
//  Peanot
//
//  Created by Steven Thienvanich on 10/24/26.
//

import SwiftUI
import VisionKit
import Vision

enum ScanMode: Hashable, CaseIterable {
    case barcode
    case text

    var recognizedDataTypes: Set<DataScannerViewController.RecognizedDataType> {
        switch self {
        case .barcode:
            [.barcode(symbologies: [.qr, .code128, .ean13, .ean8, .upce])]
        case .text:
            [.text()]
        }
    }

    var title: String {
        switch self {
            case .barcode: "Barcode"
            case .text: "Ingredients"
        }
    }

    var symbol: String {
        switch self {
            case .barcode: "barcode.viewfinder"
            case .text: "text.viewfinder"
        }
    }
}

struct DataScannerView: UIViewControllerRepresentable {
    let mode: ScanMode
    @Binding var recognizedText: String
    @Binding var recognizedTextItems: [String]

    init(
        mode: ScanMode = .barcode,
        recognizedText: Binding<String>,
        recognizedTextItems: Binding<[String]> = .constant([])
    ) {
        self.mode = mode
        self._recognizedText = recognizedText
        self._recognizedTextItems = recognizedTextItems
    }

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: mode.recognizedDataTypes,
            qualityLevel: mode == .text ? .accurate : .balanced,
            recognizesMultipleItems: mode == .text,
            isHighFrameRateTrackingEnabled: true,
            isHighlightingEnabled: true
        )

        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ scanner: DataScannerViewController, context: Context) {
        context.coordinator.parent = self
        
        guard !scanner.isScanning else { return }

        do {
            try scanner.startScanning()
        } catch {
            print("Scanner error: \(error)")
        }
    }

    static func dismantleUIViewController(
        _ scanner: DataScannerViewController,
        coordinator: Coordinator
    ) {
        scanner.stopScanning()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        var parent: DataScannerView
        private var hasScanned = false

        init(_ parent: DataScannerView) {
            self.parent = parent
        }

        func dataScanner(
            _ dataScanner: DataScannerViewController,
            didAdd addedItems: [RecognizedItem],
            allItems: [RecognizedItem]
        ) {
            handle(addedItems, allItems: allItems, in: dataScanner)
        }

        func dataScanner(
            _ dataScanner: DataScannerViewController,
            didUpdate updatedItems: [RecognizedItem],
            allItems: [RecognizedItem]
        ) {
            handle([], allItems: allItems, in: dataScanner)
        }

        func dataScanner(
            _ dataScanner: DataScannerViewController,
            didRemove removedItems: [RecognizedItem],
            allItems: [RecognizedItem]
        ) {
            handle([], allItems: allItems, in: dataScanner)
        }

        private func handle(
            _ addedItems: [RecognizedItem],
            allItems: [RecognizedItem],
            in dataScanner: DataScannerViewController
        ) {
            switch parent.mode {
            case .barcode:
                guard !hasScanned else { return }

                for item in addedItems {
                    if case .barcode(let barcode) = item,
                       let payload = barcode.payloadStringValue {

                        hasScanned = true
                        parent.recognizedText = payload
                        dataScanner.stopScanning()
                        break
                    }
                }

            case .text:
                let items = allItems
                    .compactMap { item -> (text: String, x: CGFloat, y: CGFloat)? in
                        guard case .text(let text) = item else { return nil }

                        let bounds = item.bounds
                        return (
                            text.transcript,
                            bounds.topLeft.x,
                            bounds.topLeft.y
                        )
                    }
                    .sorted {
                        abs($0.y - $1.y) < 16 ? $0.x < $1.x : $0.y < $1.y
                    }
                    .map(\.text)

                parent.recognizedTextItems = items
            }
        }
    }
}
