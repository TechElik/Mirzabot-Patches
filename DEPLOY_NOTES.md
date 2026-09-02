English | 🌐 [فارسی](./DEPLOY_NOTES.fa.md)

# Changes in this fork compared to the original mirzabot

Latest update: includes stability fixes + a complete premium-emoji icon system for keyboard buttons, tutorial categories/names, and shop products/categories.

---

## 1. Changed files (17 files, all applied via `git pull` or `apply-patches.sh`)

```
admin.php
function.php
index.php
table.php
keyboard.php
lang/fa.php
api/miniapp.php
api/users.php
cronbot/gift.php
cronbot/lottery.php
cronbot/payment_expire.php
cronbot/plisio.php
cronbot/uptime_panel.php
vpnbot/Default/admin.php
vpnbot/Default/index.php
vpnbot/update/admin.php
vpnbot/update/index.php
```

`config.php` is never part of these changes and is always left untouched.

---

## 2. Stability and bug fixes

| Item | Description |
|---|---|
| Case-sensitive `parse_mode` | `'html'` (lowercase) → `'HTML'` in 239 places. Without this fix, no HTML tag (including premium emoji) was ever parsed. |
| Payment-gateway timeouts | 5 curl calls in `function.php` that previously used `CURLOPT_TIMEOUT => 0` (unlimited) now cap out at 20 seconds. This prevents PHP-FPM workers from hanging forever. |
| PHP-FPM tuning | This project's `install.sh` automatically applies `request_terminate_timeout = 30s` and `pm.max_children = 12` after install. If you use `apply-patches.sh`, it does the same thing. |

---

## 3. Premium emoji icon system — fully managed from inside the bot

None of this requires SSH or phpMyAdmin; everything is done from the bot's admin panel by sending the premium emoji directly (the bot extracts `custom_emoji_id` from the message's `entities` itself).

### a) Main keyboard buttons (14 items)
Path: **✏️ Edit Bot Texts → 🎨 Keyboard Button Icons**

Covers: Buy subscription, My services, Extend, Test account, Wallet, Add balance, Pricing, Support, Tutorials, Referrals, Gift code, Lucky wheel, FAQ, Send message to support.

This list is **fixed and always available** — even buttons that are currently disabled (like the lucky wheel) can be picked, so their icon is already set once they're turned on.

The text of these buttons can also be changed from the same menu (without an icon, just by sending new text).

Database column: `setting.buttonIcons`

### b) Tutorial categories and individual tutorial names
Path: admin panel → manage tutorials → pick a tutorial to edit → the edit keyboard has these buttons:
```
[Edit name]           [Edit description]
[Edit media]          [Edit category]
[🎨 Category icon]     [🎨 Tutorial icon]
```
- The category icon affects every tutorial in that category
- The tutorial icon only affects that one specific tutorial

Works whether the "category" feature is enabled or disabled.

Database columns: `setting.helpCategoryIcons`, `setting.helpNameIcons`

### c) Shop products and shop categories
- **Product icon:** admin panel → manage products → edit product → the "🎨 Product icon" button next to price/volume/duration and the other options
- **Shop category icon:** admin panel → manage categories → the "🎨 Shop category icon" button (shows a list of all categories, pick one)

Database columns: `setting.productIcons`, `setting.shopCategoryIcons`

### d) App download links
Path: admin panel → app management menu (next to "🔗 Add app" and "✏️ Edit app") → the "🎨 App icon" button (shows a list of all apps, pick one)

Both the entry button's text ("🔗 App download link") and its icon can be changed from "✏️ Edit Bot Texts" and "🎨 Keyboard Button Icons" respectively — that's separate from the icon of each individual app inside the list.

Each app is identified by its real `id` from the `app` table (not its name), so multiple apps sharing the same display name never collide.

Database column: `setting.appLinkIcons`

---

## 4. What to do after every install/update

### With the script (recommended)
```bash
curl -o apply-patches.sh -L https://raw.githubusercontent.com/TechElik/Mirzabot-Patches/main/apply-patches.sh
sudo bash apply-patches.sh
```
The menu has 5 options — pick the one matching your situation:
- **Option 1** — fresh install, no bot installed yet (runs our pre-patched `install.sh`)
- **Option 2** — you have an older mirzabot version installed; brings it up to base 0.3.1 first (does not apply our patches by itself)
- **Option 3** — you already have mirzabot 0.3.1 installed; applies our patches (auto-installatin folder and database backup, replaces the files, runs `table.php`, tunes PHP-FPM)
- **Option 4** — restore a previous backup (only installationfolder backups)
- **Option 5** — delete old backups (only installationfolder backups)

If you're on an older version, run option 2, then option 3 right after.

### Manually (if you don't want to use the script)
1. Replace the 17 files listed above (leave `config.php` untouched)
2. Run `php8.2 table.php` (for the new columns: `helpCategoryIcons`, `helpNameIcons`, `buttonIcons`, `productIcons`, `shopCategoryIcons`, `appLinkIcons`)
3. Apply the PHP-FPM settings manually (section 2 of this file)
4. `sudo systemctl restart php8.2-fpm`

---

## 5. `setup_icons.sql` is no longer necessary

Since every icon can now be set from inside the bot itself, this SQL file is no longer the primary method — it's kept only for bulk-seeding several icons at once ahead of time (e.g. when migrating an older bot), and is entirely optional.

---

## 6. Guide: inserting premium emoji into the bot's free-text messages (not buttons)

This is separate from the button icon system — it's for when you want to place an animated premium emoji inside a **regular message** (like the rules, welcome message, or any text you edit from "✏️ Edit Bot Texts").

### Why this differs from button icons
Buttons (`icon_custom_emoji_id`) use a field that's completely separate from the button's text — but message text (like the rules) is an ordinary HTML string processed with `parse_mode=HTML`, so you have to place the emoji directly **inside the text itself** using a special HTML tag.

### Steps

**1. Get the emoji's identifier (`custom_emoji_id`)**
Forward the original message containing that animated premium sticker to one of these bots:
- @RawDataBot
- @JsonDumpBot

In the JSON reply they send you, look for the `entities` section; you'll see a field called `custom_emoji_id` — usually a 19-digit number. Copy it.

**2. Build the final text with the tag**
Wherever you want the premium emoji to appear in the text, use this tag:
```html
<tg-emoji emoji-id="THE_EMOJI_NUMERIC_ID">fallback_emoji</tg-emoji>
```
Real example:
```html
<tg-emoji emoji-id="5312361253610475399">✅</tg-emoji> Using this service for criminal activity is forbidden.
```
Note: the character you place between `<tg-emoji>` and `</tg-emoji>` (here ✅) is the **fallback** — if the animation can't be shown for any reason (e.g. the owner isn't Premium), this plain emoji is shown instead. So pick something visually close to the actual sticker.

**3. Send it through the bot's official flow**
As the admin:
1. Open the "✏️ Edit Bot Texts" menu
2. Pick the text you want to edit (e.g. "Rules text")
3. Send the complete final text (including the `tg-emoji` tags) in one message

**4. Test**
Using a **non-admin** account (since many admin-facing messages aren't shown to admins), check that section of the bot and confirm the animated emoji actually renders.

### A few important notes
- You can have multiple `tg-emoji` tags (with different IDs) in a single piece of text.
- If you want the emoji to render **larger than normal**, it needs to be alone on its own line with no other text at all (not even a space) — Telegram automatically renders emoji-only paragraphs larger; this is client-side behavior, not something the bot can control.
- The same requirement as always applies: the bot's owner account (the one that created it in BotFather) must have Telegram Premium.
- If you've followed all these steps and still only see the plain fallback emoji, there are two likely causes: either the owner isn't Premium, or the emoji ID was copied incorrectly/incompletely (it must be the exact full number from RawDataBot's output).

## 7. Mandatory Telegram requirement

The account that created the bot in BotFather (the actual owner, not just an internal bot admin) must have an active **Telegram Premium** subscription — otherwise none of these icons will render as animated, and only the fallback emoji will be shown.
