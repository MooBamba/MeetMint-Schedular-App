# MeetMint

An appointment scheduling interface for independent professionals and business teams.

## What is scaffolded

- A host dashboard with a weekly calendar and upcoming appointments
- Availability controls for weekly working hours, meeting length, buffers, notice, and scheduling horizon
- A public booking-page preview with calendar-based date selection and available time slots
- A confirmation interaction after booking
- Calendar connection and email-confirmation states in the product interface

## Current status

The static dashboard is connected to the hosted Supabase project `aguaqpnaeayzkoicgill`. Public booking-page data loads through the Supabase REST API, and completed bookings are stored through a conflict-checking Postgres function protected by row-level security. Dashboard authentication, calendar-provider synchronization, and transactional email delivery remain prototype states.

## Next implementation milestones

1. Connect the existing sign-in interface to Supabase Auth and assign the host profile owner.
2. Integrate a calendar provider and include busy events in slot calculation.
3. Add confirmation email delivery and calendar-event creation.
4. Add cancellation, retries, monitoring, and automated end-to-end coverage.

## Local structure

- `dist/index.html` — interactive static prototype
- `dist/supabase-config.js` — public Supabase URL and publishable browser key
- `supabase/migrations/` — versioned database schema, RLS policies, and booking RPC
- `supabase/config.toml` — local Supabase CLI configuration
- `appointment-scheduler-product-brief.md` — V1 product requirements
