# Peanot

Know what's in it, before you eat it.

Peanot is an iOS app that scans a product's barcode or ingredient label and checks it against your own allergy profile. You pick the allergens you avoid once; after that, every scan comes back as **avoid**, **caution**, or **no listed allergens**, with the specific ingredients that triggered the verdict highlighted.

> [!WARNING]
> **Peanot is not a medical device.** Verdicts are produced in part by an AI model and can be wrong, including false "no listed allergens" results. Always read the packaging yourself. If you have a severe allergy, do not rely on this app alone.

## How it works

1. **Scan** — `DataScannerView` uses VisionKit to read a barcode or ingredient text from the camera.
2. **Look up** — a barcode is resolved to a product through the Edamam Food Database API.
3. **Prescreen** — `AllergenPrescreen` matches the ingredient text against a local keyword list (milk → whey, casein) with no network call. This catches obvious matches instantly and cheaply.
4. **Analyze** — `AnalyzeService` sends the ingredients and your selected allergens to OpenAI (`gpt-5-mini`) for an in depth analysis.
5. **Results** — `ResultsView` shows the verdict with ingredients highlighted.

## Privacy

Your name and allergy preferences are stored locally on your device using `UserDefaults`. Scan history is stored locally using `SwiftData`. The app has no analytics, tracking, or account system.

When analyzing a product, Peanot may transmit the product name, ingredient text, and selected allergens to third-party APIs, including OpenAI and Edamam. Your name and scan history are not intentionally transmitted.

## Requirements

- Xcode 26 or later
- iOS 26.5 or later
- OpenAI API key
- Edamam Food Database API credentials

## Setup

### 1. Clone the repository

Clone Peanot to your local machine:

### 2. Configure API credentials

Create a `Secrets.xcconfig` file using the provided template and add your API credentials:

```
OPENAI_API_KEY = YOUR_OPENAI_API_KEY
EDAMAM_APP_ID = YOUR_EDAMAM_APP_ID
EDAMAM_APP_KEY = YOUR_EDAMAM_APP_KEY
```

> [!CAUTION]
> **Keep your API credentials private.**
>
> Never commit `Secrets.xcconfig` to version control. API keys embedded in an iOS application can be extracted from the compiled app. This configuration is intended for local development only. Production deployments should use a secure backend to handle secret API credentials.

### 3. Open the project in Xcode

Open the Peanot Xcode project and select your development team under **Signing & Capabilities**.

### 4. Build and run

> [!NOTE]
> Peanot requires a compatible physical iPhone for its VisionKit camera-scanning functionality.

## Project structure

```
Peanot/
├── App/              Entry point and root view
├── Models/           Allergen, Product, RecentScan
├── Services/         API clients, analysis, prescreen, persistence
├── Features/
│   ├── Onboarding/   Welcome → name → allergen selection → review
│   ├── Home/         Greeting, allergy profile, recent scans
│   ├── Scan/         VisionKit camera and scanning
│   ├── Search/       Search products by name
│   └── Results/      Verdict and highlighted ingredients
├── DesignSystem/     Colors, typography, spacing, shared components
└── Resources/        Assets
```

The design system under `DesignSystem/` holds the tokens (`PeanotColors`, `PeanotTypography`, `PeanotSpacing`) and shared components.

## License

Peanot's source code is licensed under the Apache License, Version 2.0.

Copyright 2026 Steven Thienvanich.

Trademarks and Branding

The Peanot™ name, logo, and original branding are reserved by Steven Thienvanich and are not licensed for reuse under the Apache License 2.0.

The Apache License 2.0 permits the use, modification, and distribution of the licensed source code, but does not grant trademark rights to the Peanot name or logo.

Unless otherwise expressly authorized in writing, no permission is granted to use the Peanot name, logo, or original branding assets.

All rights to original Peanot branding are reserved.
