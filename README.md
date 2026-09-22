# MeetMint

An appointment scheduling interface for independent professionals and business teams.

## What is scaffolded

- A host dashboard with a weekly calendar and upcoming appointments
- Availability controls for weekly working hours, meeting length, buffers, notice, and scheduling horizon
- A public booking-page preview with calendar-based date selection and available time slots
- A confirmation interaction after booking
- Calendar connection and email-confirmation states in the product interface

## Current status

This is a front-end prototype designed from `appointment-scheduler-product-brief.md`. It uses representative data and browser-only interactions; it does not yet connect to Google or Microsoft calendars, send real email, authenticate users, or store appointments.

## Next implementation milestones

1. Add authentication, PostgreSQL/Prisma schema, and host profiles.
2. Integrate a calendar provider, then implement conflict-safe availability and slot calculation.
3. Add booking persistence, Resend confirmation emails, and calendar-event creation.
4. Add cancellation, retries, monitoring, and automated end-to-end coverage.

## Local structure

- `dist/index.html` — interactive static prototype
- `appointment-scheduler-product-brief.md` — V1 product requirements

