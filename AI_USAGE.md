# AI usage notes

## Tools and models

- **GitHub Copilot (agent mode) inside Xcode.** It read and edited files, ran shell commands (`xcodebuild`, `git`, `grep`) and checked editor diagnostics. The underlying model is not shown to me by the tool, so I can't state it accurately.
- No other AI tools were used.

## Agent instruction files

None. The repo has no `CLAUDE.md`, `AGENTS.md`, `.cursor/rules` or Copilot instructions file, so there is nothing to commit. Everything was steered through chat prompts.

## Plan or spec

No written plan or spec. I worked in small, incremental requests, one behaviour at a time, and reviewed the result of each before the next. The resulting decisions are recorded in `DECISIONS.md`.

## Key prompts and moments that shaped the solution

1. **"keep below only …"** (five routes). This fixed the API surface and the shape of `Endpoint` and the repository protocol. Only three of the five existed, so two were added rather than removed.
2. **"Keep home, category and search tab … /products/featured … sample response"** reset the app to a three-tab skeleton and set the product shape the decoders target.
3. **"When selecting category, don't call again API since already fetchAllProducts results are saved"** turned the Category tab into fetch-once, filter-in-memory.
4. **"Whenever I go to details screen and come back, the APIs getting called"** led to load-on-first-appearance in the view models, and to resetting state on cancellation so a cancelled first load can retry.
5. **"Update unit test cases, mocks for all the business logics, data, API layer"** produced the test support types (stub repository, stub API client, `URLProtocol` mock) and 86 tests, which were run and pass.

## Where the AI got things wrong and how it was caught

- **Edits that never reached disk (the details page wouldn't open).** After I asked for tappable product cards, the assistant reported the change as done. The app still did nothing on tap. You reported "Product detail page is not redirecting." Reading the file from the terminal showed `HomeView.swift` still had the old plain rows. The assistant's file-read tool and the Xcode editor were showing a different version from what was on disk. The fix was to rewrite the file and verify with `cat`/`grep` on disk, not just the editor. The same mismatch appeared again with `SearchView.swift` and `APIClient.swift` (the editor still showed the old version after the refactor). If a file in Xcode looks stale, reload it from disk before editing it, or an old buffer can overwrite the new file.
- **Claims based only on editor diagnostics.** For most of the work, "no errors" came from the editor's error check, not a build. I didn't build or run tests until the unit-test step. After that the assistant ran `xcodebuild test`, which found a warning the editor had missed (a main-actor-isolation warning in `NetworkLogger`), fixed with a `nonisolated` extension.
- **Non-`Sendable` test arguments.** A parameterized test passed `[String: Any]` dictionaries, which Swift Testing doesn't allow. This was also caught on review and replaced with a loop.
- **Cancellation edge case.** The first "don't reload" fix would have left a screen stuck on the loading spinner if the user navigated away mid-load. This was spotted by reasoning about task cancellation, and state now resets to idle on cancellation (covered by tests).
