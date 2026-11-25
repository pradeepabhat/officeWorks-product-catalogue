# Office Works Product Catalogue

A SwiftUI iOS app for browsing a product catalogue. It has Home, Category and Search tabs, a product details page and an enquiry form.

## Features

- **Home:** "Featured" is selected by default and shows `/products/featured`. Unselect it to show all products from `/fetchAllProducts`.
- **Category:** a dropdown filled from `/categories`, with "All" as the default. Products are fetched once and filtered in memory.
- **Search:** type a term and press the keyboard's search key to call `/products/search?q=<term>`.
- **Product details:** tap any product card to open it. The page loads `/products?id=<id>`.
- **Enquire:** a form with name, email and the product name. Submitting shows a thank-you message. It isn't sent anywhere yet.

## API

All requests are `GET`. The base URL defaults to `http://localhost:3000/` and can be changed with an `API_BASE_URL` key in the Info.plist.

| Endpoint | Used for |
| --- | --- |
| `/products/featured` | Home, Featured selected |
| `/fetchAllProducts` | Home (Featured unselected), Category |
| `/categories` | Category dropdown |
| `/products/search?q=<term>` | Search |
| `/products?id=<id>` | Product details |

Expected product shape:

```json
{
  "id": 1,
  "title": "string",
  "price": 0.1,
  "description": "string",
  "category": "string",
  "image": "http://example.com"
}
```

`/categories` returns an array of strings, for example `["men's clothing", "jewelery"]`. The decoders also accept a few alternative shapes (see `DECISIONS.md`).

## Requirements

- Xcode with the iOS 26 SDK
- An API running at the base URL above

## Run

1. Open `officeWorksProducts.xcodeproj`.
2. Select the `officeWorksProducts` scheme and an iPhone simulator.
3. Press ⌘R.

Network requests and responses are logged to the Xcode console (category "Network").

## Test

Press ⌘U, or run:

```bash
xcodebuild test -scheme officeWorksProducts \
  -destination 'platform=iOS Simulator,name=<simulator name>' \
  -only-testing:officeWorksProductsTests
```

The unit tests cover the network, data and view-model layers, and need no running API. There are no UI tests.

## Project structure

```
officeWorksProducts/
├── Core/          Network client, endpoints, errors, logging, LoadState
├── Data/          DTOs and the remote repository
├── Domain/        Product model and the repository protocol
├── ViewModels/    Home, Category, Search and ProductDetail view models
└── Features/      SwiftUI views (tabs, details page, enquiry form, shared card)
officeWorksProductsTests/
├── Core/          Endpoint, APIClient and error tests
├── Data/          Decoding and repository tests
├── ViewModels/    View model tests
└── Support/       Stubs and test data
```

Views talk to view models, view models talk to `CatalogRepositoryProtocol`, and only the data layer knows about URLs and DTOs.

## More documentation

- [`DECISIONS.md`](DECISIONS.md): assumptions, what was simplified, and next steps.
- [`AI_USAGE.md`](AI_USAGE.md): how AI was used, and where it got things wrong.
