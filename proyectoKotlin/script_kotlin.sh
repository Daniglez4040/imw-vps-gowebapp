```bash
#!/bin/bash

# This script deploys a Kotlin (Ktor) web application on an already
# prepared Ubuntu 24.04 LTS server.
# It installs Java & Gradle requirements, builds the app and
# configures it as a systemd service.

set -euo pipefail

# --- AESTHETICS ---

GREEN='\033[0;32m'
ALIEN='\xF0\x9F\x91\xBD'
NC='\033[0m'

# --- CONFIGURATION ---

APP_NAME="kotlinweb"
APP_USER="user"
APP_DIR="/home/user/kotlinweb"
APP_PORT="9090"
JAR_NAME="kotlinweb.jar"
SERVICE_NAME="kotlinweb"

# --- HELPER FUNCTIONS ---

log() {
    echo -e "${GREEN}${ALIEN} $1${NC}"
}

# --- INSTALL FUNCTIONS ---

install_java() {
    log "Installing OpenJDK 21..."
    sudo apt-get update -y
    sudo apt-get install -y openjdk-21-jdk
}

verify_java() {
    log "Verifying Java installation..."
    java -version
}

# --- BUILD FUNCTIONS ---

build_application() {
    log "Building Kotlin application with Gradle..."

    cd "$APP_DIR"

    if [ ! -f "./gradlew" ]; then
        log "Gradle wrapper not found!"
        exit 1
    fi

    ./gradlew clean
    ./gradlew build
}

verify_jar() {
    if [ ! -f "$APP_DIR/build/libs/$JAR_NAME" ]; then
        log "JAR file not found after build!"
        exit 1
    fi

    log "JAR successfully built."
}

# --- SYSTEMD SETUP ---

create_systemd_service() {
    log "Creating systemd service..."

    sudo tee /etc/systemd/system/${SERVICE_NAME}.service > /dev/null <<EOF
[Unit]
Description=Kotlin Web App (Ktor)
After=network.target

[Service]
Type=simple
User=${APP_USER}
WorkingDirectory=${APP_DIR}
ExecStart=/usr/bin/java -jar ${APP_DIR}/build/libs/${JAR_NAME}
Restart=always
RestartSec=10
Environment=JAVA_OPTS=-Xms128m

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable ${SERVICE_NAME}
}

# --- MAIN SCRIPT ---

log "Starting deployment of ${APP_NAME}..."

install_java
verify_java
build_application
verify_jar
create_systemd_service

log "Starting application service..."
sudo systemctl restart ${SERVICE_NAME}

log "Checking service status..."
sudo systemctl status ${SERVICE_NAME} --no-pager

log "Deployment completed successfully."
log "Application should now be available on port ${APP_PORT}."

# --- POST-DEPLOYMENT INFO ---

cat << EOF

POST-DEPLOYMENT NOTES:

- Application directory:
  ${APP_DIR}

- Service name:
  ${SERVICE_NAME}

- Logs:
  journalctl -u ${SERVICE_NAME} -f

- Restart service:
  sudo systemctl restart ${SERVICE_NAME}

- If using Caddy or another reverse proxy,
  ensure traffic is forwarded to port ${APP_PORT}

EOF
```
