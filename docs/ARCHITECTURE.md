\# ChurchMate — System Architecture



\## Overview

Users (Youth Leaders \& Youth Members) log in through one unified account

system, which routes them into three modules — Faith, Library, and Finance —

all backed by one shared Firestore database, feeding one unified dashboard.



\## Flow

1\. Youth Leaders \& Members open the app and log in

2\. Unified Account System verifies credentials and checks role (leader/member)

3\. Both roles access the same three modules, with different permissions:

&#x20;  - Faith Module — QR attendance, events, tasks

&#x20;  - Library Module — catalog, borrowing, holds

&#x20;  - Finance Module — budget, expenses, transactions

4\. All three modules read/write to the same Shared Database (Firestore) —

&#x20;  see docs/DATABASE\_SCHEMA.md for the actual collections

5\. The Shared Database feeds the Unified Dashboard, which shows attendance,

&#x20;  library, and financial overview in one place, plus notifications

&#x20;  (event reminders, overdue books, budget alerts, task assignments)



\## Why this matters

Every module depends on the same account system and database — this is why

the Unified Account System (Week 3) is built jointly before either of us

starts on module-specific work.

