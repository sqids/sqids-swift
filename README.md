# [Sqids Swift](https://sqids.org/swift)

[![Github Actions](https://img.shields.io/github/actions/workflow/status/sqids/sqids-swift/tests.yml)](https://github.com/sqids/sqids-swift/actions)

[Sqids](https://sqids.org/swift) (*pronounced "squids"*) is a small library that lets you **generate unique IDs from numbers**. It's good for link shortening, fast & URL-safe ID generation and decoding back into numbers for quicker database lookups.

Features:

- **Encode multiple numbers** - generate short IDs from one or several non-negative numbers
- **Quick decoding** - easily decode IDs back into numbers
- **Unique IDs** - generate unique IDs by shuffling the alphabet once
- **ID padding** - provide minimum length to make IDs more uniform
- **URL safe** - auto-generated IDs do not contain common profanity
- **Randomized output** - Sequential input provides nonconsecutive IDs
- **Many implementations** - Support for [40+ programming languages](https://sqids.org/)

## 🧰 Use-cases

Good for:

- Generating IDs for public URLs (eg: link shortening)
- Generating IDs for internal systems (eg: event tracking)
- Decoding for quicker database lookups (eg: by primary keys)

Not good for:

- Sensitive data (this is not an encryption library)
- User IDs (can be decoded revealing user count)

## 🚀 Getting started

Add the following dependency to your Swift `Package.swift`:

```swift
dependencies.append(
    .package(url: "https://github.com/sqids/sqids-swift.git", from: "0.1.0")
)
```

Import the `Sqids` struct from the `sqids` framework:

```swift
import sqids

let sqids = Sqids()
```

## 👩‍💻 Examples

Simple encode & decode:

```swift
let sqids = Sqids()
let id = try sqids.encode([1, 2, 3]) // "86Rf07"
let numbers = try sqids.decode(id) // [1, 2, 3]
```

> **Note**
> 🚧 Because of the algorithm's design, **multiple IDs can decode back into the same sequence of numbers**. If it's important to your design that IDs are canonical, you have to manually re-encode decoded numbers and check that the generated ID matches.

Enforce a *minimum* length for IDs:

```swift
let sqids = Sqids(minLength: 10)
let id = try sqids.encode([1, 2, 3]) // "86Rf07xd4z"
let numbers = try sqids.decode(id) // [1, 2, 3]
```

Randomize IDs by providing a custom alphabet:

```swift
let sqids = Sqids(alphabet: "FxnXM1kBN6cuhsAvjW3Co7l2RePyY8DwaU04Tzt9fHQrqSVKdpimLGIJOgb5ZE")
let id = try sqids.encode([1, 2, 3]) // "B4aajs"
let numbers = try sqids.decode(id) // [1, 2, 3]
```

Prevent specific words from appearing anywhere in the auto-generated IDs:

```swift
let sqids = Sqids(blocklist: ["86Rf07"])
let id = try sqids.encode([1, 2, 3]) // "se8ojk"
let numbers = try sqids.decode(id) # [1, 2, 3]
```

## 📝 License

[MIT](LICENSE)
