# 4. Settings keys and formats are redesigned now and frozen from 2.0

- Status: Accepted (2026-10-07, #95)

## Context

#94 stored settings in App Group `UserDefaults` (`regions`, `sunnyLevel`) with a rule that the format is never migrated. Version 1 never used `UserDefaults`: it kept everything in Realm (checked in `v1.0.1`). The #94 keys were added on `main` and have not been released, so no user has them.

#94 also chose, for reasons that still hold:

- Regions are stored as a list from the start, even with one entry, so multiple regions later need no format change.
- Each region gets an ID when it is added (a UUID; a fixed ID for the current location). Cached forecasts are keyed by the ID, not by coordinates, so they don't depend on coordinate precision, and the current location has one stable cache entry.
- Cached forecasts of removed regions are deleted.

## Decision

- The new modules ([0001](0001-modules-in-local-packages.md)) choose their own keys and formats now; nothing reads the #94 keys.
- The #94 design reasons above are kept.
- **From the 2.0 release on, stored settings are never migrated** and tests pin their format.
- Version 1's Realm data is still not migrated; the app keeps deleting the old `db.realm*` files at launch.

## Considered options

- *Keep the #94 keys and JSON as they are.* Protects data no user has, and ties the new modules to the old model layout.
