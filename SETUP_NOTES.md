# ChurchMate — Implementation Notes (this pass)

This documents what was changed in the existing project and — importantly —
the manual steps you still need to do in the Firebase console / native
projects before everything works end-to-end. Nothing here was rebuilt from
scratch: the existing screens, theme, navigation and Firebase project wiring
were kept and filled in.

## What changed in the code

- **Models** (`lib/features/*/models/*.dart`, `lib/shared/models/app_user.dart`)
  Were empty comment stubs → now real classes with `fromMap`/`toMap` matching
  the Firestore schema in `firestore.rules`.
- **Auth** (`lib/core/services/auth_service.dart`)
  Email/password login + register (unchanged behavior, cleaned up) **plus**
  Google Sign-In (`signInWithGoogle`), profile editing with photo upload
  (`updateProfile`), and password reset e-mail (`sendPasswordResetEmail`).
- **Storage** (`lib/core/services/storage_service.dart`, new)
  Uploads profile photos / book covers / event images to Firebase Storage.
- **QR attendance** (`lib/features/faith/services/qr_service.dart`)
  QR codes now encode `{eventId, token}` and the token rotates every 90
  seconds and is stored on the event doc, so a screenshot stops working
  quickly and can't be replayed for another event. Check-in writes an
  `attendance/{eventId}_{userId}` doc — the deterministic ID is what makes a
  duplicate scan impossible (Firestore rules enforce this server-side too).
- **Every screen** listed in the request — Login, Dashboard, Events (list /
  detail / create-edit form), Library (catalog / detail / add-edit form),
  Giving (ledger / add-edit transaction form), Profile / Edit Profile,
  Attendance Scanner, QR Display — was rewired to real Firestore streams, has
  proper empty states, and real Create/Edit/Delete flows with confirmation
  dialogs. No hardcoded "Sister Hannah", sample events, sample books, or fake
  peso amounts remain anywhere in the app; a brand-new Firebase project will
  show all-empty state until real data is added.
- **Firestore/Storage security rules** (`firestore.rules`, `storage.rules`,
  new) — added at the project root and wired into `firebase.json`. See the
  comments in those files for the role model (`users/{uid}.role` is `"member"`
  or `"leader"`).

## Manual steps you still need to do

These require access to your Firebase console / signing keys, which isn't
something that can be done from inside the code:

1. **Enable Google as a sign-in provider** — Firebase Console → Authentication
   → Sign-in method → enable Google.
2. **Register your app's SHA-1/SHA-256 fingerprint** (Android) — Firebase
   Console → Project settings → your Android app → Add fingerprint. Without
   this, Google Sign-In on Android fails with `ApiException: 10`. Get your
   debug fingerprint with `cd android && ./gradlew signingReport`. After
   adding it, re-download `google-services.json` (or re-run
   `flutterfire configure`) and replace `android/app/google-services.json`.
3. **iOS Firebase config is missing** — only the Android app is fully wired
   (`android/app/google-services.json` exists; there's no
   `ios/Runner/GoogleService-Info.plist`). Run `flutterfire configure` again
   and select iOS to generate it, then add the reversed client ID URL scheme
   Xcode will show you (needed for Google Sign-In on iOS).
4. **Firebase Storage requires the Blaze (pay-as-you-go) plan.** Profile
   photos, book covers, and event images all go through Firebase Storage —
   upgrade the project's billing plan if it's still on Spark.
5. **Deploy the security rules**: `firebase deploy --only firestore:rules,storage`
   (requires the Firebase CLI logged into this project).
6. **`flutter pub get`** — this pass added `google_sign_in` and
   `mobile_scanner` to `pubspec.yaml`.
7. Camera permission was added to `android/app/src/main/AndroidManifest.xml`
   and `NSCameraUsageDescription`/`NSPhotoLibraryUsageDescription` to
   `ios/Runner/Info.plist` for the QR scanner and photo pickers — no action
   needed, just noting it.

## Known simplification

The original project's `borrow_model.dart` (checking a book in/out to a
specific member) was left as a stub — the spec's Library requirement is
about adding/removing books and managing available-copy counts, which is
fully implemented (Add Book, Edit, Delete, +/- available copies). A full
borrow/return-to-a-specific-person workflow wasn't part of the existing
project and would be a separate feature to design if you want it.


## Role separation update (Youth Member vs Youth Leader)

- Login is role-locked: an account registered as Youth Member can only sign in
  from the "Youth Member" tab, and a Youth Leader only from the "Youth Leader"
  tab (email and Google). Wrong tab = error message + signed out.
- Youth Member dashboard: upcoming events made by the leader, available books
  with a Borrow button. No Giving (hidden + blocked by route guard + rules).
- Youth Leader dashboard: create events, Borrow Requests card with Accept /
  Decline, library (add/edit books, Accept requests, Returned), and Giving.
- New Firestore collection `borrowRequests` (see firestore.rules).
- **Redeploy the rules**: `firebase deploy --only firestore:rules`
