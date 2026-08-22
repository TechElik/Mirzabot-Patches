-- نکته: از این به بعد نیازی به این فایل نیست — آیکون دکمه‌ها و دسته‌بندی‌های آموزش
-- مستقیم از داخل خودِ ربات (منوی «✏️ ویرایش متن‌های ربات» یا داخل ویرایش هر آموزش) قابل تنظیمه.
-- این فایل فقط برای حالت خاص «تنظیم گروهی و یکجای چند آیکون از قبل» نگه داشته شده، اختیاریه.

-- اجرا کن فقط بعد از این‌که یه‌بار table.php رو زدی (تا ستون helpCategoryIcons ساخته بشه)
-- SELECT id FROM setting;  -- نیازی نیست، جدول setting فقط یک ردیف دارد و بدون شرط WHERE کار می‌کند

-- ۱) آیکون روی دکمه‌ی "خرید اشتراک" در کیبورد اصلی
UPDATE setting
SET keyboardmain = '{"keyboard":[[{"text":"text_usertest","style":"danger"},{"text":"text_Tariff_list","style":"danger"}],[{"text":"text_sell","style":"danger","icon_custom_emoji_id":"5312361253610475399"}],[{"text":"text_Purchased_services"},{"text":"text_extend"}],[{"text":"accountwallet","style":"success"}],[{"text":"text_support","style":"success"},{"text":"text_help","style":"success"}]]}';

-- ۲) نگاشت آیکون هر دسته‌بندی آموزش (کلید = اسم دقیق دسته‌بندی در جدول help، مقدار = custom_emoji_id)
--    مثال‌ها را با اسم واقعی دسته‌بندی‌ها و شناسه‌های واقعی جایگزین کن
UPDATE setting
SET helpCategoryIcons = '{"نصب اپلیکیشن":"5312361253610475399"}';

-- بررسی نتیجه:
SELECT keyboardmain, helpCategoryIcons FROM setting;
