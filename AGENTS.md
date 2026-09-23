# MeetMint agent guide

## Project

MeetMint is a static appointment-scheduling prototype. The complete interface,
styles, and interactions live in `dist/index.html`.

## Working conventions

- Preserve the existing MeetMint visual system: calm white surfaces, navy
  navigation, and blue interaction states.
- Keep the dashboard responsive across desktop, tablet, and phone widths.
- Treat the Day, Week, and Month calendar views as one connected experience.
- Use semantic controls, accessible labels, keyboard support, and visible focus
  states for new interactions.
- Avoid dependencies or build tooling unless explicitly required; this is a
  self-contained static site.
- Preserve working navigation, account menu, notifications, appointment
  composer, and calendar filters.

## Verification

- Check for unintended horizontal scrolling at supported breakpoints.
- Confirm new controls work with pointer and keyboard input when applicable.

## Publishing

- The site is hosted through the Sites workflow with `dist` as its static
  directory.
- Publish requested site changes to the existing private MeetMint deployment.
