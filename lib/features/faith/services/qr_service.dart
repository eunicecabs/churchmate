// Handles QR generation (Leader side) and validation (Member side).
//
// Generation: create a unique code value per event, store valid_from/valid_until
// in Firestore (QR_CODES table from your ERD), render with qr_flutter.
//
// Validation on scan: look up the code, check current time is within
// [valid_from, valid_until], check it matches the event being scanned for,
// then write an ATTENDANCE record for (event_id, user_id). This is what
// makes the check-in "time-sensitive" and prevents screenshot proxy attendance.
