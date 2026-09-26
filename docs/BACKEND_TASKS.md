\# Backend Handoff — What Frontend Needs From You



Frontend status: 8 of 9 screens built (Login/Register, Dashboard, QR Display,

Events List, Event Detail, Library Catalog, Book Detail, Finance). All UI is

done — every screen currently uses hardcoded dummy data and placeholder

buttons. Your job: replace the dummy data with real Firebase logic, following

the schema in docs/DATABASE\_SCHEMA.md and the diagram in docs/ARCHITECTURE.md.



Existing stub files already in the repo for you to fill in:

\- lib/core/services/auth\_service.dart

\- lib/core/services/firestore\_service.dart

\- lib/core/services/notification\_service.dart

\- lib/features/faith/services/qr\_service.dart

\- lib/features/finance/services/budget\_service.dart



\## Priority order (matches how frontend was built — do the same order)



\### 1. Auth (unlocks everything else)

\- Firestore `users` collection: id (= Firebase Auth UID), fullName, email, role

\- `AuthService.register(fullName, email, password, role)` — creates Firebase

&#x20; Auth user + matching Firestore user doc

\- `AuthService.login(email, password)` — returns success/error

\- `AuthService.getCurrentUserRole()` — reads role, used to route Leader vs

&#x20; Member views

\- Wire into: lib/features/auth/screens/login\_screen.dart (currently just

&#x20; navigates to Dashboard with no real check)



\### 2. Faith Module — QR check-in (the mandatory feature)

\- `qrCodes` collection: eventId, codeValue, validFrom, validUntil

\- `attendance` collection: eventId, userId, checkedInAt

\- `QrService.generateCode(eventId)` — creates a new doc in qrCodes with a

&#x20; \~90 second expiry (see the countdown timer logic already built in

&#x20; lib/features/faith/screens/qr\_display\_screen.dart — it currently generates

&#x20; a fake local token, needs to write/read from Firestore instead)

\- `QrService.validateAndCheckIn(codeValue, userId)` — checks the code hasn't

&#x20; expired, then writes an attendance doc

\- Real-time listener for "X checked in" count on both the QR Display and

&#x20; Event Detail screens (currently hardcoded to 48/65)



\### 3. Faith Module — Events

\- `events` collection: title, activityType, eventDate, location, createdBy

\- CRUD for events (Leader creates/edits), list + detail fetch (Member/Leader

&#x20; view)

\- Wire into: events\_list\_screen.dart and event\_detail\_screen.dart (currently

&#x20; 4 hardcoded event cards)



\### 4. Library Module

\- `books` collection: title, author, coverImageUrl, status

\- `borrowRecords` collection: bookId, userId, borrowedDate, dueDate, returnedDate

\- `reservations` collection: bookId, userId, reservedAt

\- Wire into: library\_catalog\_screen.dart, book\_detail\_screen.dart (currently

&#x20; 3 hardcoded books)



\### 5. Finance Module

\- `transactions` collection: transactionType, amount, category, recordedBy,

&#x20; transactionDate, approvalStatus

\- Budget balance = sum of all transactions (do this client-side or in

&#x20; BudgetService, no Cloud Functions needed — see note below)

\- Approval workflow: Leader-only action to flip approvalStatus

\- Wire into: finance\_screen.dart (currently hardcoded ₱18,450 balance and

&#x20; 3 ledger rows)



\## Important constraint

We deliberately do NOT use Cloud Functions or Firebase Storage yet (both

require the paid Blaze plan). Do all logic client-side in Flutter/Dart,

reading/writing Firestore directly. Ask before adding anything that would

require Blaze.



\## Blocked / not started

\- Member QR Scanner screen (needs `mobile\_scanner` package, which crashes

&#x20; the build on Eunice's laptop — being worked around separately, don't

&#x20; build backend logic for this one yet until the frontend screen exists)

