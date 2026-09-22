# MeetMint — V1 Product Brief

**One-line description:** MeetMint is a simple appointment scheduler that lets independent professionals share availability, let clients book a time, and automatically confirm the meeting by email.

## Product Vision

Make scheduling a professional meeting feel effortless: no email back-and-forth, no accidental double-bookings, and no uncertainty about what happens next.

## Problem Statement

Business professionals and freelancers lose time coordinating meetings through email and chat. Comparing calendars, clarifying time zones, and confirming details is repetitive and error-prone. Existing tools can feel too complex or expensive for someone who mainly needs a reliable booking link, clear availability controls, and professional confirmations.

MeetMint gives a host one dependable place to publish bookable time, while giving invitees a fast, reassuring booking experience.

## Target Users

### Primary: Independent professional

A 28–45-year-old consultant, coach, recruiter, designer, lawyer, or service provider who books client calls and discovery sessions. They need to protect focus time, avoid double-bookings, and look polished without administrative overhead.

**Key need:** Share a booking link that reflects real availability and sends confirmation automatically.

### Primary: Busy business professional

A 30–50-year-old manager, account executive, founder, or operations lead who coordinates internal or external meetings. They value speed, predictability, and calendar accuracy.

**Key need:** Let others choose an appropriate time without manual coordination.

### Secondary: Meeting invitee

A client, prospect, candidate, or colleague booking time with a host. They may not have an account and should be able to complete booking in under a minute.

**Key need:** See clear time options in their local time zone and receive immediate confirmation.

## Core Features — V1

### 1. Account setup and calendar connection

Hosts create an account and connect one Google or Microsoft calendar. MeetMint reads busy times to prevent conflicts and writes confirmed bookings to that calendar.

**User stories**

- As a host, I want to sign up and connect my calendar so that my availability is accurate from the start.
- As a host, I want MeetMint to avoid times already marked busy so that I am never double-booked.
- As a host, I want booked appointments added to my calendar so that my schedule remains in one place.

### 2. Availability management

Hosts define weekly working hours, appointment duration, buffer time, minimum notice, and date range for booking. They can add one-off unavailable periods.

**User stories**

- As a host, I want to set the days and hours I accept meetings so that bookings respect my working routine.
- As a host, I want buffers before or after meetings so that I have time to prepare or recover.
- As a host, I want to block a specific period so that I can protect leave, travel, or focus time.

### 3. Shareable booking page with calendar view

Each host has a public booking page with a monthly or weekly calendar-style date picker and available time slots. Invitees select a date and time, provide their name and email, and submit the booking.

**User stories**

- As a host, I want a shareable booking link so that I can put it in my email signature, website, or messages.
- As an invitee, I want to browse available days and times in a calendar view so that I can quickly find a suitable appointment.
- As an invitee, I want times shown in my local time zone so that I can book with confidence.

### 4. Booking confirmation and calendar invitations

Once a booking succeeds, MeetMint creates calendar events for the host and invitee and emails both parties a confirmation containing the appointment details and a calendar invitation.

**User stories**

- As an invitee, I want immediate email confirmation so that I know the appointment is secured.
- As a host, I want a confirmation notification so that I know when someone books me.
- As both parties, I want calendar events created automatically so that the meeting is not forgotten.

### 5. Host appointments dashboard

Hosts can see upcoming appointments, filter by date, and cancel an appointment. Cancellation updates the calendar event and emails the invitee.

**User stories**

- As a host, I want one view of upcoming bookings so that I can prepare for my day.
- As a host, I want to cancel a booking when necessary so that the invitee is informed and my calendar stays accurate.
- As a host, I want cancelled meetings removed or marked clearly so that I do not act on stale appointments.

## Explicitly Out of Scope for V1

- Payments, invoices, packages, subscriptions, or deposits
- Two-way rescheduling by invitees (hosts can cancel; invitees contact the host)
- Teams, multiple hosts, round-robin scheduling, or shared calendars
- Video-conferencing provisioning or integrations beyond an optional meeting-link field
- SMS, WhatsApp, push notifications, or reminder sequences
- Custom branding, custom domains, multilingual interface, or white-labeling
- Native mobile apps
- CRM, analytics, accounting, or marketing automation integrations
- Complex recurring appointments and group/event scheduling

## Recommended Tech Stack

| Layer | Recommendation | Why it fits V1 |
| --- | --- | --- |
| Web app | Next.js + TypeScript | One codebase for the host dashboard and public booking pages, with strong production conventions. |
| UI | Tailwind CSS + shadcn/ui | Fast, accessible, professional interface development without a heavy design-system investment. |
| Database | PostgreSQL | Reliable relational model for users, availability rules, bookings, and audit history. |
| Database access | Prisma ORM | Type-safe schema and migrations; developer-friendly for a small product team. |
| Authentication | Auth.js | Supports email/passwordless and OAuth flows while fitting naturally into Next.js. |
| Calendar integration | Nylas (recommended) or direct Google/Microsoft APIs | Nylas reduces integration complexity; direct APIs are viable when minimizing recurring vendor cost is more important. |
| Email | Resend | Straightforward transactional email delivery and templates for confirmations/cancellations. |
| Background jobs | Trigger.dev | Reliable async processing for calendar writes, retries, and email delivery. |
| Hosting | Vercel | Simple deployment and preview workflow for a Next.js product. |
| Error monitoring | Sentry | Detects booking and integration failures before they become support incidents. |
| Testing | Vitest + Playwright | Unit coverage for availability logic and end-to-end coverage for the booking flow. |

**Architecture note:** Store all appointment times in UTC and render them in the viewer’s detected or selected IANA time zone. Availability calculation must combine the host’s rules, one-off blocks, and connected-calendar busy events before exposing any slot.

## Key Data Objects

- **User:** Host account, profile, default time zone, connected-calendar identity.
- **Booking page:** Public slug, meeting title, duration, location/meeting-link text, and active status.
- **Availability rule:** Weekly day/time windows, minimum notice, scheduling horizon, and buffer settings.
- **Unavailable period:** One-off start/end block created by the host.
- **Appointment:** Host, invitee, start/end in UTC, status, calendar-event references, and cancellation metadata.
- **Calendar connection:** Provider, authorization state, selected calendar, and sync health.

## Definition of Done — V1

V1 is ready to launch when all of the following are true:

- A new host can sign up, connect a supported calendar, configure availability, and publish a booking link without support.
- The booking page shows only valid future slots after applying time zone, working hours, buffers, notice period, one-off blocks, and existing busy events.
- Two invitees cannot successfully reserve the same slot, including when they attempt it at nearly the same time.
- A successful booking creates host and invitee calendar events and sends confirmation emails to both parties.
- A host cancellation updates/removes the calendar events and sends a cancellation email to the invitee.
- Booking and cancellation failures are retried safely, visible to operators, and do not silently leave an ambiguous appointment state.
- Core flows meet accessibility basics: keyboard navigation, visible focus states, labeled form fields, adequate color contrast, and meaningful error messages.
- The booking flow works on current Chrome, Safari, Edge, and mobile browser viewports.
- Automated tests cover availability calculation, conflict prevention, booking confirmation, and cancellation; end-to-end tests cover the happy path.
- Privacy essentials are in place: HTTPS, encrypted provider credentials, minimal personal-data collection, a privacy notice, and account deletion/export plan.

## Success Metrics for the First 90 Days

- **Activation:** Percentage of new hosts who connect a calendar and publish a booking page within 15 minutes.
- **Booking completion:** Percentage of invitees who complete booking after opening a booking page.
- **Reliability:** Percentage of confirmed bookings that create both calendar events and both emails successfully.
- **Conflict rate:** Number of confirmed double-bookings per 1,000 appointments (target: zero).
- **Host retention:** Percentage of activated hosts with at least one booking in the following 30 days.

## Suggested Delivery Sequence

1. Build authentication, host profile, calendar connection, and the appointment data model.
2. Implement availability rules and thoroughly test slot generation and conflict prevention.
3. Build the public booking calendar and transactional booking flow.
4. Add calendar-event creation, email confirmations, retries, and monitoring.
5. Build the host dashboard and cancellation flow; run accessibility and end-to-end quality checks.

