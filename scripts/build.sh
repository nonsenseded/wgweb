#!/bin/bash

# Output file
OUTPUT="wgweb.bash"

echo "#!/bin/bash" > "$OUTPUT"
echo "# ==============================================" >> "$OUTPUT"
echo "# WireGuard Web UI All-in-One Installer" >> "$OUTPUT"
echo "# ==============================================" >> "$OUTPUT"
echo "" >> "$OUTPUT"

# Add helper functions
echo "# --- Helper Functions ---" >> "$OUTPUT"
cat scripts/helpers.sh >> "$OUTPUT"
echo "" >> "$OUTPUT"

# Add main install logic
echo "# --- Main Install Script ---" >> "$OUTPUT"
cat scripts/install.sh >> "$OUTPUT"
echo "" >> "$OUTPUT"

# Add uninstall logic
echo "# --- Uninstall Script ---" >> "$OUTPUT"
cat scripts/uninstall.sh >> "$OUTPUT"
echo "" >> "$OUTPUT"

# Add Python backend as heredoc
echo "# --- Python Web Server ---" >> "$OUTPUT"
echo "cat <<'EOF' > /path/to/webserver/server.py" >> "$OUTPUT"
cat backend/server.py >> "$OUTPUT"
echo "EOF" >> "$OUTPUT"
echo "" >> "$OUTPUT"

# Add systemd service file as heredoc
echo "# --- Systemd Service File ---" >> "$OUTPUT"
echo "cat <<'EOF' > /etc/systemd/system/wg-web.service" >> "$OUTPUT"
cat systemd/wg-web.service >> "$OUTPUT"
echo "EOF" >> "$OUTPUT"
echo "" >> "$OUTPUT"

# Add example WireGuard config
echo "# --- Example WireGuard Config ---" >> "$OUTPUT"
echo "cat <<'EOF' > /etc/wireguard/wg0.conf.example" >> "$OUTPUT"
cat config/wg0.conf.example >> "$OUTPUT"
echo "EOF" >> "$OUTPUT"
echo "" >> "$OUTPUT"

echo "All-in-one installer script generated: $OUTPUT"