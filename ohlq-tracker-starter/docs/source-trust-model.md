# Source Trust Model

## Purpose
This document defines how the app should rank conflicting evidence.

## Trust order
1. OHLQ official event pages
2. OHLQ store/location inventory pages
3. OHLQ product pages with explicit release or quantity limits
4. Selected tracked X accounts with strong historical reliability
5. Reddit posts with exact store + bottle + recent timestamp
6. Reddit comments and weak rumor posts

## Core rule
Community data can elevate confidence but cannot override a direct contradiction from a fresher official source without manual review.

## Signal categories
### Official event
Examples:
- bonus release page
- release event page
- participating location list

Base score: 0.95

### Official inventory
Examples:
- store inventory page
- location inventory listing

Base score: 0.85

### Trusted tracked account
Examples:
- selected X user with consistent reporting

Base score: 0.72

### Strong Reddit post
Criteria:
- includes specific store
- includes bottle name or accepted alias
- posted within 24 hours of claim
- language suggests firsthand observation

Base score: 0.62

### Weak community rumor
Criteria:
- missing exact store or time
- hearsay language
- no corroboration

Base score: 0.25

## Freshness decay
Suggested half-life:
- official event: until event end time, then hard drop
- official inventory: 12 hours
- trusted tracked account: 8 hours
- Reddit post: 6 hours
- Reddit comment: 3 hours

## Corroboration boosts
Additive boosts:
- +0.08 for second independent source
- +0.05 for third independent source
- +0.05 if source timing matches known store release day/time pattern
- +0.04 if bottle/store pair has historical consistency

## Penalties
- -0.20 if store resolution is ambiguous
- -0.20 if bottle resolution is ambiguous
- -0.15 if wording is speculative
- -0.25 if official source contradicts the claim
- -0.10 if the signal is copied or cross-posted without firsthand language

## Confidence bands
- 0.85 to 1.00 = confirmed or near-confirmed
- 0.65 to 0.84 = likely
- 0.45 to 0.64 = plausible but unverified
- below 0.45 = weak signal

## UI mapping
- confirmed: green
- likely: blue-green
- unverified: amber
- weak/stale: gray-red

## Manual review triggers
Send to review when:
- official and community evidence conflict
- extracted store has multiple possible matches
- post implies a large release but confidence stays below 0.6
- a tracked account suddenly drops below its historical reliability band
