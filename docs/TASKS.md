# ChurchMate task board

This mirrors the Feature Checklist from your progress tracker, formatted so it can be turned
straight into a GitHub Projects Kanban board (recommended for a 2–3 person group — everyone
sees live status without waiting for a status meeting).

## How to set up the live board on GitHub

1. Push this repo to GitHub (create a new empty repo there first, then from this folder:
   `git remote add origin <your-repo-url>` → `git push -u origin main`).
2. On the repo page, click the **Projects** tab → **New project** → choose the **Board** template.
3. Create four columns: `Backlog`, `In Progress`, `In Review`, `Done`.
4. For each task below, click **+ Add item** and paste the task title — or better, create it as a
   **GitHub Issue** first (Issues tab → New issue), assign it to a teammate, tag it with a label
   matching its module (`faith`, `library`, `finance`, `common`), then add that issue to the board.
   Issues let you leave comments, link the pull request that closes them, and keep a history —
   plain board cards don't.
5. Drag cards across columns as you work. This *is* your live "Status" column from the xlsx
   tracker — update both, or treat the GitHub board as the source of truth once you're coding.

## Backlog — Week 1 (this week)

- [ ] Confirm tech stack: Flutter + Firebase (done, per this conversation)
- [ ] Each member installs Flutter SDK + Android Studio/VS Code
- [ ] Create the GitHub repo, push this scaffold
- [ ] Create Firebase project, enable Auth + Firestore + Storage + Messaging
- [ ] Set up the GitHub Projects board using the steps above
- [ ] Assign module ownership (suggested for a 3-person group: one person per module —
      Faith, Library, Finance — with the shared account/dashboard work split or paired)

## Backlog — Common / Unified (assign across the group)

- [ ] Unified account system: registration + secure login (Firebase Auth)
- [ ] Role-based access control (`role` field: leader / member)
- [ ] Unified dashboard shell (navigation + summary tiles)
- [ ] Unified notification system (Firebase Cloud Messaging wiring)

## Backlog — Faith module

- [ ] Event creation/management screen (Leader)
- [ ] QR code generation (unique, time-sensitive, per event)
- [ ] QR scan check-in (Member)
- [ ] Real-time attendance monitoring dashboard (Leader)
- [ ] Push notification reminders (24–48 hrs before event)
- [ ] Attendance report export (PDF/CSV)
- [ ] Member participation history
- [ ] Task assignment + confirmation

## Backlog — Library module

- [ ] Book catalog management (add/edit/view) + cover image upload
- [ ] Borrow/return transaction recording
- [ ] Book status display (Available / Borrowed / Missing)
- [ ] Overdue book alerts
- [ ] Book reservation / hold feature
- [ ] Personal borrowing history
- [ ] Search by author / keyword

## Backlog — Finance module

- [ ] Record donations, tithes, offerings
- [ ] Record + categorize expenses
- [ ] Role-based expense approval workflow
- [ ] Automatic budget balance calculation
- [ ] Financial report export (PDF/CSV)
- [ ] Monthly financial summary dashboard
- [ ] Search/filter transactions (date/type/category)

## Milestones

- **Midterm (Week 6, Oct 12–18):** Common features + full Faith module (including QR
  attendance) demo-ready.
- **Finals (Week 10, Nov 9–15):** All three modules integrated, tested, documented, and
  presentation-ready.
