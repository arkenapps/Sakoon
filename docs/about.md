# About Sakoon — سكون

*Why this app exists, how it computes the sky, and what it actually solves.*

---

## The moment that inspired it

Walk through any mall in Dubai, Riyadh, or Doha when the azaan begins, and
something quietly remarkable happens: the music stops. Not because someone
ran to a control room — the building itself observes the moment. For a few
minutes there is stillness, and then life resumes exactly where it left off.

Your PC doesn't do that. You're deep in work with music playing, a YouTube
video running, a game going — and the azaan sounds from the mosque next
door or your phone while your speakers keep playing over it. You scramble
for the volume key, or you feel that small discomfort of not having done
so. Multiply that by five prayers a day, every day.

**Sakoon gives your desktop the same manners as the mall.** One minute
before each azaan it mutes your audio, holds the silence through the
azaan, and unmutes afterwards. You never touch a key. That's the whole
idea — small, respectful, automatic. The name means *stillness*, and that's
exactly what it delivers, five times a day.

## The problem, precisely

Prayer times are not one schedule. They differ **by country and by
emirate** — Dubai and Abu Dhabi are minutes apart; Sharjah differs again.
Each authority (UAE's awqaf bodies, Saudi's Umm al-Qura, Qatar's Awqaf
ministry, Egypt's Survey Authority, and so on) publishes its own monthly
table. So a useful azaan app must answer two hard questions:

1. **What time is the azaan *here*, according to *my* authority?**
2. **How do I mute and restore audio reliably, without ever leaving the
   PC stuck silent?**

Most apps answer the first question with a generic calculation and ignore
the second entirely. Sakoon treats both as the actual engineering problem.

## How the timing works — astronomy, not astrology

A quick distinction worth making: prayer times have nothing to do with
astrology (star signs, horoscopes). They are **pure astronomy** — the
measurable position of the sun. This is one of the oldest applied sciences
in Islamic civilisation: *ʿilm al-mīqāt*, the science of timekeeping, was
practised by mosque astronomers (*muwaqqits*) for a thousand years, using
instruments like the astrolabe. Sakoon's circular dial is a small homage
to exactly that instrument.

Each prayer is defined by a solar event:

| Prayer | Solar definition |
|---|---|
| **Fajr** | Sun is ~18–19.5° *below* the eastern horizon — first true dawn light (the exact angle is set by each authority) |
| **Sunrise** | Upper edge of the sun crosses the horizon (prayers pause; shown for reference) |
| **Dhuhr** | Sun crosses the local meridian — the moment just after its highest point (*zawāl*) |
| **Asr** | An object's shadow equals its own length plus its noon shadow |
| **Maghrib** | Upper edge of the sun sinks below the western horizon |
| **Isha** | Sun is ~17–18° below the western horizon — last twilight gone (or, in the Umm al-Qura convention, 90 minutes after Maghrib) |

To compute these, Sakoon does what a modern muwaqqit would:

1. **Julian day** — converts the calendar date into a continuous
   astronomical day count.
2. **Solar declination** — how far north or south of the equator the sun
   stands that day (why Fajr drifts later through July and Maghrib earlier).
3. **Equation of time** — the correction between sundial time and clock
   time (the Earth's orbit is an ellipse and its axis is tilted, so solar
   noon wobbles ±16 minutes across the year).
4. **Hour angle** — for a given sun altitude (say, 18.2° below the horizon
   for Dubai's Fajr), trigonometry on your latitude and the declination
   yields how many hours before or after solar noon that altitude occurs.
5. **Asr geometry** — the shadow-length rule becomes an altitude via an
   arctangent, then feeds the same hour-angle machinery.

That's the entire pipeline: date → sun position → angles → clock times.
No lookup services, no internet — your machine computes the sky locally,
in microseconds, for any date.

## Why official tables still outrank the math

Here's the subtle part, and Sakoon is built around it: **the official
times are deliberately not the astronomical times.** Authorities add small
precaution minutes (*iḥtiyāṭ*) and their own longitude conventions, so the
published table sits a few minutes off any pure calculation — by design,
and they are right to do so.

So Sakoon's philosophy is:

- **Official uploaded tables are the source of truth.** You upload your
  authority's monthly CSV/Excel; it's stored versioned and checksummed,
  never overwritten.
- **The calculation is a fallback**, always badged *CALCULATED —
  UNOFFICIAL* in warning colour.
- **The math becomes a watchdog.** The Verify tab shows official-minus-
  calculated per day. A small, *stable* delta (the precaution offset) means
  a healthy upload. A sudden jump past ±10 minutes means a shifted column
  or corrupted file — caught instantly, before it ever mutes at the wrong
  time.

The astronomy doesn't replace the authority; it *guards* the authority's
data. That's the honest division of labour.

## The muting engineering

The second problem is where most attempts would quietly fail. Sakoon's
audio layer follows five rules, each one a real failure mode it prevents:

1. **Mute the endpoint, never move the slider** — Sakoon mutes and
   unmutes the output device and leaves your volume level exactly where
   you set it. Nothing to re-adjust afterwards.
2. **Capture and restore, never toggle** — if you were already muted,
   Sakoon leaves you muted afterwards; it restores the state it found,
   not a state it assumes.
3. **Crash-proof** — the restore information is written to disk *before*
   audio is touched. If the app dies mid-window, the next start finds the
   orphaned record and restores your sound. A PC can never be left
   permanently silent.
4. **Sleep-proof and replay-proof** — a wall-clock check every second
   survives laptop sleep, and a missed azaan is never replayed twenty
   minutes late.
5. **You always win** — unmute during a window and Sakoon stands down;
   plug in headphones mid-azaan and it follows the new device. And a
   tray snooze (30 min / 2 h) covers meetings.

## What it is — and what it is not

Sakoon is a convenience and a courtesy, built with respect. It is **not a
religious authority**: where its display and your awqaf or mosque differ,
they are right and Sakoon is wrong. And it should never be your only
reminder for prayer — software can fail; the intention to pray shouldn't
depend on it.

It runs entirely on your machine inside its own app window — no network
ports are opened — sends nothing anywhere,
needs no account, shows no ads, and stores everything as plain files you
can read and delete. Free for personal use, from **ArkenApps** — and if it
brings a little stillness to your day, a du'a for those who built it is
more than enough.
