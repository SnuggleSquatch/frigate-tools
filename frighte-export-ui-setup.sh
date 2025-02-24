#!/bin/bash
# This script installs Apache and PHP, creates the necessary index.html and export.php files
# in the web root (/var/www/html/exportui), and sets up a simple site accessible at
# http://frigate.snuggleshome.com/exportui.
# Intended for Debian/Ubuntu-based systems. Run as root or with sudo.

set -e

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or with sudo."
  exit 1
fi

echo "Updating package list..."
apt-get update

echo "Installing Apache, PHP, and PHP cURL extension..."
apt-get install -y apache2 php libapache2-mod-php php-curl

# Define the base web directory (Apache's DocumentRoot)
SUB_DIR="exportui"
WEB_DIR="/var/www/html"

# Create a subdirectory "exportui" for your UI
FULL_DIR="$WEB_DIR/$SUB_DIR"
echo "Creating directory $FULL_DIR..."
mkdir -p "$FULL_DIR"

echo "Creating index.html in $FULL_DIR..."
cat > "$FULL_DIR/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Frigate Export UI</title>
</head>
<body>
  <h2>Frigate Export UI</h2>
  <form action="export.php" method="post">
    <label for="camera">Camera Name:</label>
    <input type="text" id="camera" name="camera" placeholder="Camera Name" required>
    <br><br>
    <label for="start-date">Start Date:</label>
    <input type="date" id="start-date" name="start_date" required>
    <label for="start-time">Start Time:</label>
    <input type="time" id="start-time" name="start_time" step="1" required>
    <br><br>
    <label for="end-date">End Date:</label>
    <input type="date" id="end-date" name="end_date" required>
    <label for="end-time">End Time:</label>
    <input type="time" id="end-time" name="end_time" step="1" required>
    <br><br>
    <fieldset>
      <legend>Select Playback Mode:</legend>
      <input type="radio" id="playback_timelapse" name="playback" value="timelapse_25x" checked>
      <label for="playback_timelapse">Timelapse</label>
      <input type="radio" id="playback_realtime" name="playback" value="realtime">
      <label for="playback_realtime">Realtime</label>
    </fieldset>
    <br><br>
    <input type="submit" value="Export">
  </form>
</body>
</html>
EOF

echo "Creating export.php in $FULL_DIR..."
cat > "$FULL_DIR/export.php" << 'EOF'
<?php
// export.php

date_default_timezone_set('America/Denver');

// Retrieve form inputs
$camera    = $_POST['camera'];
$startDate = $_POST['start_date'];
$startTime = $_POST['start_time'];
$endDate   = $_POST['end_date'];
$endTime   = $_POST['end_time'];
$playback  = $_POST['playback'];

if (!$camera || !$startDate || !$startTime || !$endDate || !$endTime) {
    die("Please fill in all fields.");
}

// Convert date/time values to UNIX timestamps
$startTimestamp = strtotime("$startDate $startTime");
$endTimestamp   = strtotime("$endDate $endTime");

// Map the code values to nicer display names
$playbackDisplayNames = [
    'realtime'      => 'Realtime',
    'timelapse_25x' => 'Timelapse'
];
$playback_display = isset($playbackDisplayNames[$playback]) ? $playbackDisplayNames[$playback] : $playback;

// Format export name as "Camera Name - Start Date - Start Time-End Time - PlaybackDisplay"
$exportName = "$camera - $startDate - $startTime-$endTime - $playback_display";

// Build the export URL
$exportUrl = "http://localhost:5000/api/export/$camera/start/$startTimestamp/end/$endTimestamp";

// Create the payload for the export call
$exportPayload = json_encode([
    "playback"   => $playback,
    "source"     => "recordings",
    "name"       => $exportName,
    "image_path" => ""
]);

// Initialize a cURL session for the export call
$ch = curl_init($exportUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, $exportPayload);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    "Content-Type: application/json",
    "Accept: application/json"
]);

$exportResponse = curl_exec($ch);
if (curl_errno($ch)) {
    die("Export error: " . curl_error($ch));
}
$exportHttpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

if ($exportHttpCode === 200) {
    echo '<html>';
    echo '<head>';
    echo '<meta http-equiv="refresh" content="5;url=https://frigate.example.com/export">';
    echo '<title>Export Started</title>';
    echo '</head>';
    echo '<body>';
    echo '<p>Export started successfully!</p>';
    echo '<p>Export name: <strong>' . htmlspecialchars($exportName) . '</strong></p>';
    echo '</body>';
    echo '</html>';
} else {
    echo "Export failed: " . $exportResponse;
}
?>
EOF

echo "Setting ownership and permissions for $FULL_DIR..."
chown -R www-data:www-data "$FULL_DIR"
chmod -R 755 "$FULL_DIR"

echo "Restarting Apache..."
systemctl restart apache2

echo "Setup complete."
echo "Access the export tool at: http://(YOUR_IP_HERE)-OR-(YOUR_FQDN_HERE)/exportui"
