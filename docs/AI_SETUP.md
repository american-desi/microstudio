# Setting up the AI creation assistant

The AI panel in the editor is powered by a hosted LLM. You bring your own API key via `config.json` (in the repo root, next to `README.md` — never commit it). The panel is hidden until a key is configured.

## Recommended: free hosted tiers (no local install, no credit card)

| Provider | Free tier (mid-2026) | Get a key |
|---|---|---|
| **Google Gemini** (default) | ~1,500 requests/day on Gemini Flash, 1M context | [Google AI Studio](https://aistudio.google.com/apikey) |
| **Groq** | ~1,000 requests/day, Llama 3.3 70B at 700+ tok/s | [console.groq.com](https://console.groq.com/keys) |
| **OpenRouter** | 20 req/min across 28+ free models on one key | [openrouter.ai](https://openrouter.ai/keys) |
| Anthropic (paid) | — | [console.anthropic.com](https://console.anthropic.com/) |

**Recommendation:** Gemini Flash for the best free capacity and code quality; Groq if you want the fastest responses. Free tiers comfortably cover development and a small classroom; for larger deployments, budget a paid tier — pricing per student stays in pennies with small models.

## Configuration

Minimal `config.json` (Gemini):

```json
{
  "realm": "local",
  "ai_provider": "gemini",
  "ai_api_key": "YOUR_GOOGLE_AI_STUDIO_KEY"
}
```

Groq: `"ai_provider": "groq"`. OpenRouter: `"ai_provider": "openrouter"`. Anthropic: `"ai_provider": "anthropic"`.

All options:

| Option | Description | Default |
|---|---|---|
| `ai_provider` | `gemini`, `groq`, `openrouter`, `anthropic`, or omit with a custom `ai_base_url` | `anthropic` (or `openai` when `ai_base_url` is set) |
| `ai_api_key` | Your API key (required to enable the panel) | — |
| `ai_model` | Model ID at the provider | per provider: `gemini-2.5-flash`, `llama-3.3-70b-versatile`, `google/gemini-2.5-flash`, `claude-haiku-4-5` |
| `ai_base_url` | Any OpenAI-compatible endpoint (e.g. a school-hosted proxy) | per provider |
| `ai_max_tokens` | Max response length | `3000` |
| `ai_hourly_limit` | Per-user requests per hour | `40` |

Restart the server after changing `config.json`.
