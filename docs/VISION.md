# Vision — The Hub Where You Learn Anything by Making and Playing

*Version 2 — amended after a simulated 400-voice global panel review (100 experts, 100 parents, 100 teachers, 100 students; see [PANEL_REVIEW.md](PANEL_REVIEW.md)).*

## Core thesis

Creation is the deepest form of learning (Papert's constructionism). To build a working game about photosynthesis or fractions, a student must actually understand photosynthesis or fractions — the plant dies if the model is wrong. Learning is the game's physics, not gamification bolted on.

Two loops on one knowledge graph:

- **Learn by playing** — a library of learning games, each tagged to a knowledge graph of concepts and curriculum standards. Mastery is measured inside play, not by a quiz after it.
- **Learn by making** — students build games with an AI assistant ("vibe coding"), and publishing becomes the new book report. Every learner's game teaches the next kid: content scales with users.

A student's profile is the map of knowledge-graph nodes they've lit up — by playing, making, and teaching others. A skill tree, not a leaderboard.

**Anti-chocolate-covered-broccoli stance (panel's most-praised element — do not soften):** some things should not be gamified. Simulation fits science and economics; narrative/role-play fits history and literature; puzzles fit math and logic; spaced repetition fits facts, vocabulary, and language. For novels and essays, we build interactive companions, never replacements.

## The three panel-mandated corrections

1. **The comprehension gate moves off the publish button.** Publishing to class/friends/unlisted is instant — publishing IS the reward. The AI comprehension dialogue gates only the **Verified Creator** tier: marketplace featuring, knowledge-graph credit, cross-school distribution, and (later, adults only) monetization. Passing is leveling up a creator rank; failure is private and retryable; teachers can override; every decision has a plain-language rationale and a human appeal path. Assessment is **debugging-based** (diagnose a deliberately broken variant of your own game) rather than an oral exam — harder to jailbreak, better evidence, and it respects ELL/IEP/shy students with accommodation modes and native-language assessment.

2. **Phase 1 is built for schools and households that actually exist.** One beachhead domain at launch (middle-school physical science/math + CS), a seeded marketplace of 200–500 commissioned games via paid jams and a **paid teacher-creator program** (teachers are first-class paid creators and reviewers, not free labor), school plumbing from day one (Clever/ClassLink/Google SSO, LTI 1.3, pre-signed DPA templates, GDPR with EU data residency and a self-hostable tier), offline-first PWA + classroom-pod local server for low-bandwidth contexts, touch-friendly phone creation, shared-device profiles, and country launches gated on native-language AI plus mapping to that country's actual exams (WAEC/JAMB, KCSE, ENEM, Tawjihi, JEE/CBSE, suneung, GCSE/Abitur/Bac). Honest unit economics published before scale: inference + human moderation priced per student; district-level pricing ($15–50k) in the US, purchasing-power-adjusted per-student pricing with ministry/NGO channels elsewhere.

3. **No money near minors; the far phases shrink to a vision slide.** Paid peer tutoring between minors and minor revenue splits are off the roadmap. In their place: a non-cash credential ladder — verified-creator certificates, portable portfolio credentials for applications, cosmetics earned from knowledge nodes, prize-pool game jams. The 18+ creator economy (keeping the 70%+ revenue share — panel-validated, vs Roblox's ~25–30%) lives on a firewalled separate surface. Consoles/TV/handheld ambitions leave the operating plan; the handheld concept is reborn as the **sub-$200 offline classroom pod** ministries and NGOs can buy today.

## Safety is a product, not a policy page

A separately budgeted pipeline distinct from the comprehension system: human pre-publication review for content reachable by under-13s, no open chat/DMs for minors (structured, moderated class-multiplayer and 2–4 person squad creation instead), remix-chain provenance scanning, CSAE detection with mandatory-reporting workflows, and a parent/teacher-visible review log per game. Moderation staffing ratios and SLAs published as sales collateral — the first kids' UGC platform to make moderation visible wins district trust.

The knowledge-graph profile is student/parent-owned: pseudonymous by default, full export and true deletion, children's data never trains models (contractually and technically), DPIA + UK Children's Code conformity, and a standards-mapped portfolio export. Parents get a weekly plain-language digest (WhatsApp-deliverable), a making-vs-playing breakdown, and session budgets with save-and-summary endings.

## Two faces, one product (by design)

Students told the panel the education brand is "a permission-laundering machine" — approvingly. Adults must see curriculum evidence; kids must see creator status. So: dashboards, standards tags, and mastery metrics are adult-facing; student-facing surfaces show creator rank, cosmetics, and squad leagues, and never say "learning" out loud. Class-vs-class and school-vs-school remix leagues supply the sociality kids require, inside COPPA-safe structure.

## North star

Not hours. **Independently-validated knowledge-graph nodes lit per student per week, within bounded sessions** — session caps are a feature, natural stopping points are designed in, and less time with more evidence is the win condition. A pre-registered external-validity study (ESSA Tier 3 minimum) by end of Year 1; no "verified learning" claims in marketing until it exists.

## Phases (amended)

| Phase | What | Key targets |
|---|---|---|
| **1 (Yr 0–1)** | Classroom + club wedge: AI creation panel, tiered publishing with Verified credential, seeded marketplace, teacher dashboard, school plumbing, safety pipeline, offline pod pilot. Parallel low-friction channels: after-school clubs, homeschool co-ops, libraries, CoderDojo/Code Week, tutoring centers. | 200 schools/clubs, 50k students, efficacy study underway |
| **2 (Yr 1–3)** | Creator credential economy (non-cash for minors), 3D support, game jams, mobile creation at parity, more subjects + countries (each gated on language + exam mapping) | 1M MAU, 100k creators |
| **Vision slide** | The go-to hub to learn anything by making and playing — living-room and hardware ambitions revisited only if the wedge wins | — |

## First build (this repo)

Fork of [microStudio](https://github.com/pmgl/microstudio) (MIT). Build order:

1. **AI creation panel** — chat-driven game creation/editing inside the editor, pluggable LLM backend, per-student token budget (inference must cost pennies; microScript's tiny surface means small models can serve it).
2. **Tiered publishing** — instant class/unlisted publish; Verified tier scaffolding (badge, review states, teacher override).
3. **Debugging-based comprehension check** — the Verified-tier assessment, private and retryable.
4. **Knowledge-graph tagging** — concepts + standards on projects, the seed of the skill tree.

## What kills this plan (panel-ranked)

1. Gating publishing (fixed — see correction 1). 2. A child-safety failure. 3. Negative-margin economics from unpriced moderation. 4. Building for imaginary well-connected schools. 5. The cognitive-dossier privacy liability. 6. First-session boredom from an unseeded marketplace. 7. Roblox shipping "Roblox Education" before our district relationships exist.
