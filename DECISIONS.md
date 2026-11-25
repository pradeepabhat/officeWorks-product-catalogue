# Decisions and assumptions

## Scope

A SwiftUI iOS catalogue app with three tabs (Home, Category, Search), a product details page and an enquiry form, backed by five endpoints:

| Endpoint | Used by |
| --- | --- |
| `GET /products/featured` | Home (Featured selected) |
| `GET /fetchAllProducts` | Home (Featured unselected), Category |
| `GET /categories` | Category dropdown |
| `GET /products/search?q=<term>` | Search |
| `GET /products?id=<id>` | Product details |

## Assumptions (where the requirements were unclear)

- **API contract.** Only one sample response was given (`id`, `title`, `price`, `description`, `category`, `image`), plus the `/categories` array of strings. I assumed the other endpoints return the same product shape. The decoders are deliberately tolerant: numeric or string ids and prices, alternative key names, a bare array or a `data`/`items`/`results`/`products` wrapper, and a single object either bare or wrapped. Elements that fail to decode are dropped rather than failing the whole list.
- **Base URL.** Defaults to `http://localhost:3000/` and can be overridden with an `API_BASE_URL` Info.plist key. Endpoints are appended to it, so `/fetchAllProducts` is at the root, not under `/api`.
- **Currency.** The sample has no currency, so prices are formatted as USD unless the API supplies one.
- **"Featured" button.** Treated as a toggle. Selected (the default) shows featured products. Unselected shows all products from `/fetchAllProducts`.
- **Category filtering.** `/fetchAllProducts` is called once when the tab first loads. Choosing a category filters that saved list in memory (case-insensitive match on the category name), and "All" is the default. This was an explicit instruction, not just a guess.
- **Search.** Runs only when the user presses the keyboard's search key. The query is trimmed, a blank query makes no request, and editing the text clears the previous results.
- **Reloading.** Tabs fetch on first appearance only, so returning from the details page does not refetch.
- **Details page.** Opens immediately with the data from the tapped card, then refreshes from `/products?id=<id>`. If the refresh fails, the card's data stays on screen and an error message is shown.
- **Enquiry form.** Name, email (basic format check), and the product name as read-only text. Submitting shows "Thank you and we will reach out to you shortly."



## How the design supports growth beyond the PoC

- **Layers with one-way dependencies:** `Features` (views) → `ViewModels` → `Domain` (models and the repository protocol) ← `Data` (repositories and DTOs) → `Core/Network`. Views never see DTOs or URLs.
- **Repository protocol.** View models depend on `CatalogRepositoryProtocol`, so the real, in-memory and test implementations are interchangeable. Swapping or adding a data source does not touch the UI.
- **Typed endpoints.** `Endpoint` is an enum that owns paths, query items and percent-encoding. Adding a route is one case and one repository method.
- **Network client behind a protocol** (`APIClientProtocol`), with logging separated into `NetworkLogger` and errors mapped to a single `NetworkError` that carries user-facing messages.
- **DTO → domain mapping** isolates API quirks. When the contract firms up, only the DTOs change.
- **Shared `LoadState`** gives every screen the same idle/loading/loaded/failed handling.
- **Tests** run without a network: a stub repository, a stub API client, and a `URLProtocol` mock for the real client.

## What I would do next with another day

1. Confirm the real API contract, then replace the tolerant decoders with strict ones and add contract tests.
2. Add the enquiry endpoint with an `EnquiryViewModel` (validation, submit state, error and retry) and tests.
3. Make the details view model take its repository from the app instead of creating its own, so previews and alternative data sources work everywhere.
4. Add pagination and caching: keep fetched products across tabs and add pull-to-refresh with a clear refresh policy.
5. Add image caching, placeholders and failure states.
8. Configure App Transport Security properly for non-localhost HTTP, and set up CI to build and run tests.
