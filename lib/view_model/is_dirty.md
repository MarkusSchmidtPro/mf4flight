# Analyzing Model-Centric vs. Control-Centric Dirty Checking

Tying `isDirty` directly to domain model equality rather than form-control state provides substantial practical benefits
in terms of data integrity, computational efficiency, and user experience.

Checking dirtiness at the model layer minimizes unnecessary operations, prevents redundant storage and network cycles,
and ensures the UI accurately communicates the actual persistence requirement.

## Outcomes and Advantages of Model-Centric Dirty Checking

### Prevention of Redundant I/O and Network Cost:

If a user edits a control back to its original value, enters leading/trailing whitespace that is trimmed during parsing, or formats a number identically to the underlying value, the domain model remains identical `(viewToModel() == _saved)`. A model-driven isDirty evaluates to false, disabling the Save button and preventing unnecessary database writes, network calls, and cache invalidations.

### Single Source of Truth

The domain model represents the actual persisted contract. Relying on control values can produce false positives where
the form claims to be dirty, but saving would produce an identical payload.

### Unified Business Rules:

By deriving the state from the materialized TModel, custom equality rules (e.g., ignoring transient UI metadata or
normalizations) are centralized inside domain models rather than scattered across individual form controllers.

## Architecture for Model-Driven isDirty

To make model-centric isDirty reactive in Flutter, UI controllers still emit change events, but the dirty evaluation itself is delegated to model comparison:

```
[TextEditingController / UI inputs]
│
(on change) ──► notifyListeners()
│
▼
isDirty getter ──► Safe viewToModel() vs _saved (Equality Check)
│
▼
canSave (isDirty && !isSaving && isValid) ──► Re-evaluates Save Button
```