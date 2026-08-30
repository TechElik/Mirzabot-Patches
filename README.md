# mirzabot (techelik fork)

English | 🌐 [فارسی](./README.fa.md)

Thanks to the [developer of mirzabot](https://github.com/mahdiMGF2/mirzabot) — this is a full fork of their **version 0.3.1**, with stability bug fixes and a complete animated Telegram Premium emoji system (buttons and message text) already built in.

Full change details and the emoji usage guide: [DEPLOY_NOTES.md](./DEPLOY_NOTES.md)

Use of these scripts is at the installer's own responsibility. Always back up your database before making any changes.

---

## Two install methods — which one do I need?

### 🆕 Method 1: Fresh full install (if you don't have the bot installed at all)

This runs the **same official mirzabot installer**, except every file already includes the stability fixes and premium-emoji features — no separate patch step needed.

```bash
curl -o install.sh -L https://raw.githubusercontent.com/TechElik/Mirzabot-Patches/main/install.sh && bash install.sh
```

After launching it, just follow the standard mirzabot install menu as usual (domain, bot token, database info, etc.).

### 🔧 Method 2: Patch only (if you already have mirzabot 0.3.1 installed)

If you already installed the bot and just want to add these fixes and emoji features **on top of your existing install**, without reinstalling:

```bash
curl -o apply-patches.sh -L https://raw.githubusercontent.com/TechElik/Mirzabot-Patches/main/apply-patches.sh
sudo bash apply-patches.sh
```

Choose "Apply custom patches" from the menu. The script backs everything up before making any change, and can restore it as well.

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
