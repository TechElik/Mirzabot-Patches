<?php
require_once '../config.php';
require_once '../function.php';
$textbotlang = languagechange();
require_once '../botapi.php';

$reportbackup = select("topicid", "idreport", "report", "backupfile", "select")['idreport'];
$destination = getcwd();
$setting = select("setting", "*");
$canSendReport = !isTelegramChatIdEmpty($setting['Channel_Report'] ?? '');
$sourcefir = dirname($destination);
$botlist = select("botsaz", "*", null, null, "fetchAll");

// ── بکاپ کامل پوشه با tar ──────────────────────────────────
$backup_file = "/tmp/full_backup_" . date("Y-m-d_H-i-s") . ".tar.gz";
$BOT_DIR = "/var/www/html/mirzaprobotconfig";

if (is_dir($BOT_DIR)) {
    shell_exec("tar -czf $backup_file -C /var/www/html mirzaprobotconfig 2>&1");
    
    if ($canSendReport && file_exists($backup_file)) {
        telegram('sendDocument', [
            'chat_id' => $setting['Channel_Report'],
            'message_thread_id' => $reportbackup,
            'document' => new CURLFile($backup_file),
            'caption' => "📦 Full Backup: " . basename($backup_file),
        ]);
        unlink($backup_file);
    }
}

// ── بکاپ فایل‌های خاص ──────────────────────────────────────
if ($botlist && $canSendReport) {
    foreach ($botlist as $bot) {
        $folderName = $bot['id_user'] . $bot['username'];
        shell_exec("zip -r $destination/file.zip $sourcefir/vpnbot/$folderName/data $sourcefir/vpnbot/$folderName/product.json $sourcefir/vpnbot/$folderName/product_name.json");
        telegram('sendDocument', [
            'chat_id' => $setting['Channel_Report'],
            'message_thread_id' => $reportbackup,
            'document' => new CURLFile('file.zip'),
            'caption' => "@{$bot['username']} | {$bot['id_user']}",
        ]);
        unlink('file.zip');
    }
}

// ── بکاپ دیتابیس ────────────────────────────────────────────
$backup_file_name = 'backup_' . date("Y-m-d") . '.sql';
$dbhost = empty($dbhost) ? "localhost" : $dbhost;
$command = "mysqldump -h $dbhost -u $usernamedb -p'$passworddb' --no-tablespaces --ssl-mode=DISABLED $dbname > $backup_file_name";

$output = [];
$return_var = 0;
exec($command, $output, $return_var);
if ($return_var !== 0) {
    if ($canSendReport) {
        telegram('sendmessage', [
            'chat_id' => $setting['Channel_Report'],
            'message_thread_id' => $reportbackup,
            'text' => $textbotlang['keyboard']['backupError'],
        ]);
    }
} else {
    if ($canSendReport) {
        telegram('sendDocument', [
            'chat_id' => $setting['Channel_Report'],
            'message_thread_id' => $reportbackup,
            'document' => new CURLFile($backup_file_name),
            'caption' => $textbotlang['Admin']['report']['backupCaption'],
        ]);
    }
    unlink($backup_file_name);
}
?>