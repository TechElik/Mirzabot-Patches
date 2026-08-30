# mirzabot (techelik fork)

English | 🌐 [فارسی](./README.fa.md)

Thanks to the [developer of mirzabot](https://github.com/mahdiMGF2/mirzabot) — this is a full fork of their **version 0.3.1**, with stability bug fixes and a complete animated Telegram Premium emoji system (buttons and message text) already built in.

Full change details and the emoji usage guide: [DEPLOY_NOTES.md](./DEPLOY_NOTES.md)

Use of these scripts is at the installer's own responsibility. Always back up your database before making any changes.

---

## Install methods — which one do I need?

There are two ways to get a fully patched bot: run our `install.sh` directly for a one-shot fresh install, or run `apply-patches.sh`, which gives you an interactive menu covering every scenario (fresh install, updating an old version, patching an existing 0.3.1 install, and backup management).

### 🆕 Option A: Fresh full install (if you don't have the bot installed at all)

This runs the **same official mirzabot installer**, except every file already includes the stability fixes and premium-emoji features — no separate patch step needed.

```bash
curl -o install.sh -L https://raw.githubusercontent.com/TechElik/Mirzabot-Patches/main/install.sh && bash install.sh
```

After launching it, just follow the standard mirzabot install menu as usual (domain, bot token, database info, etc.).

### 🔧 Option B: The `apply-patches.sh` menu (recommended — covers every case)

```bash
curl -o apply-patches.sh -L https://raw.githubusercontent.com/TechElik/Mirzabot-Patches/main/apply-patches.sh
sudo bash apply-patches.sh
```

This opens a menu with 5 options:

| # | Option | Who it's for |
|---|---|---|
| 1 | Install pre-patched version from scratch | You have **no bot installed** yet — same as Option A above, run from inside the menu |
| 2 | Update existing install to base version 0.3.1 | You already have mirzabot installed, but an **older version** than 0.3.1 — brings it up to 0.3.1 using the official installer (does **not** apply our patches by itself) |
| 3 | Apply custom patches | You already have **mirzabot 0.3.1** installed — applies our fixes and premium-emoji features on top, with automatic backup |
| 4 | Restore a backup | Roll back to a previous backup taken by option 3 |
| 5 | Delete old backups | Free up disk space |

If you're on an old version, run **option 2** first, then **option 3** right after — that's the full path from an old install to a fully patched one.

**⚠️ Important:** these patches were only tested against version **0.3.1**. Other versions may not work correctly — always back up your SQL database first regardless.

---

## What this fork adds

- Fixes the `parse_mode` case-sensitivity bug (which prevented HTML tags / premium emoji from rendering at all)
- Removes the risk of the service hanging in payment-gateway API calls
- Automatically tunes PHP-FPM for better stability
- A complete premium-emoji management system, built entirely inside the bot itself, covering:
  - Main keyboard buttons (including the app download link)
  - Tutorial categories and individual tutorial names
  - Shop products and shop categories
  - Free-form message text (rules, welcome message, etc.)

## Mandatory Telegram requirement

The account that created the bot in BotFather (the actual owner) must have an active **Telegram Premium** subscription, otherwise the emoji won't render as animated.
