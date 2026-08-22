# mirzabot-patches

English | 🌐 [فارسی](./README.fa.md)

Thanks to the [developer of mirzabot](https://github.com/mahdiMGF2/mirzabot) — these patches are applied on top of their free script, **version 0.3.1**. That exact version is required; other versions may not work correctly.

Use of this script is at the installer's own responsibility. The script itself backs up the bot's main folder on your server, but you should always take your own database backup as well.

Custom patches for [mahdiMGF2/mirzabot](https://github.com/mahdiMGF2/mirzabot) — stability bug fixes plus full support for animated Telegram Premium emoji (on both buttons and message text).

## For a full guide on applying and inserting emoji, see the guide below

Full details: [DEPLOY_NOTES.md](./DEPLOY_NOTES.md)

## Quick install

After launching the main installer's menu, make sure to select **version 0.3.1** from menu option 2. If you already have that version installed, skip straight to the patch-install step. Other versions may not work correctly with these patches — always back up your SQL database first regardless.

The patch script itself backs up the bot's main folder before making changes, storing the backup alongside the bot's own folder. You can restore it at any time from the script's own menu.

```bash
# 1. Standard mirzabot install (from the official repo) — pick version 0.3.1 from the menu
curl -o install.sh -L https://raw.githubusercontent.com/mahdiMGF2/mirzabot/main/install.sh && bash mirza install version 0.3.1
```

```bash
# 2. Apply these patches
curl -o apply-patches.sh -L https://raw.githubusercontent.com/techelik/mirzabot-patches/main/apply-patches.sh
sudo bash apply-patches.sh
```

## What these patches add

- Fixes the `parse_mode` case-sensitivity bug (which prevented HTML tags / premium emoji from rendering at all)
- Removes the risk of the service hanging in payment-gateway API calls
- Automatically tunes PHP-FPM for better stability
- A complete premium-emoji management system, built entirely inside the bot itself, covering:
  - Main keyboard buttons
  - Tutorial categories and individual tutorial names
  - Shop products and shop categories
  - Free-form message text (rules, welcome message, etc.)

This project is not a full fork; it runs alongside the official mirzabot install and never touches `config.php`.
