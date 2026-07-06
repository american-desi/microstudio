# Open-source foundation for the Online YC

What we build on, what we adopt next, and what we deliberately skip. Rule: the fork already gives us an editor, real-time collaboration, community, forum, and publishing — adopt a library only when it beats what's here or unlocks something new.

## Already in the stack (keep)

| Layer | What | Why it stays |
|---|---|---|
| Build environment | **microStudio** (MIT) | Browser IDE, real-time multi-user editing, cloud projects, publishing, likes/comments/forum — the collaborative core, already running |
| Editor | **Ace** | Ships with microStudio; fine until we need richer language tooling |
| Server | **Node + Express + ws** | Simple, proven, easy for contributors |

## Adopt next (in order)

1. **Yjs** (MIT) — CRDT real-time collaboration. The industry standard behind Figma-class multiplayer editing. Replaces microStudio's homegrown sync when we need cursors, presence and offline merge; pairs with Ace or CodeMirror. `yjs` + `y-websocket`.
2. **CodeMirror 6** (MIT) — modern editor upgrade path (mobile-friendly, extensible autocomplete/lint — important for phone creation and AI inline suggestions). Migrate when AI inline hints land.
3. **Official Hacker News API** (free, public) — already integrated at `/news`; no key, no scraping, YC's own data.
4. **Excalidraw** (MIT) — embeddable collaborative whiteboard for team ideation/pitch sketching. Highest value-to-effort for "founders working together."
5. **Matrix (matrix-org)** or keep the built-in forum + Discord — for team chat, don't build our own; start with the built-in forum and a Discord community, revisit self-hosted Matrix when data ownership matters.
6. **Umami** (MIT) — privacy-first analytics; creators get project dashboards without Google Analytics (a trust point given our audience).
7. **Keycloak** (Apache-2.0) — SSO/rostering (Google/Clever) when schools and orgs arrive; do not hand-roll OAuth.

## Deliberately skip for now

- **Kubernetes/Firecracker "cloud IDE" stacks** (Eclipse Che, code-server fleets) — massive ops burden; browser-executed projects already give us "build in the cloud" free of per-user servers.
- **Discourse/Flarum** — microStudio ships a forum; migrating community software is a distraction.
- **Custom LLM serving (vLLM/Ollama)** — hosted free tiers (see AI_SETUP.md) beat self-hosting on cost and ops until volume proves otherwise.
