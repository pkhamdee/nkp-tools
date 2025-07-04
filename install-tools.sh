#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
OS=linux

#################################
#### kubectl bash-completion ####
#################################
sudo yum install -y bash-completion
echo 'source /usr/share/bash-completion/bash_completion' >>~/.bashrc
echo 'source <(kubectl completion bash)' >>~/.bashrc


#############
#### k9s ####
#############
curl -sS https://webinstall.dev/k9s | bash
rm -fR ~/Downloads ~/.local/bin/webi


#################
#### kubectx ####
#################
sudo curl -Lo /usr/local/bin/kubectx https://github.com/ahmetb/kubectx/releases/latest/download/kubectx
sudo chmod +x /usr/local/bin/kubectx


################
#### kubens ####
################
sudo curl -Lo /usr/local/bin/kubens https://github.com/ahmetb/kubectx/releases/latest/download/kubens
sudo chmod +x /usr/local/bin/kubens


####################
#### kubeswitch ####
####################
sudo curl -Lo /usr/local/bin/switcher https://github.com/danielfoehrKn/kubeswitch/releases/latest/download/switcher_${OS}_amd64
sudo chmod +x /usr/local/bin/switcher


############################
#### hey - load testing ####
############################
sudo curl -Lo /usr/local/bin/hey https://hey-release.s3.us-east-2.amazonaws.com/hey_${OS}_amd64
sudo chmod +x /usr/local/bin/hey


#####################
#### code-server ####
#####################

# Define the base directory based on the current user
BASE_DIR="$HOME"

# Define file paths, content, ownership, and permissions
declare -A files=(
  ["$BASE_DIR/.config/code-server/config.yaml"]='
bind-addr: 0.0.0.0:443
auth: none
cert: true
'
  ["$BASE_DIR/.local/share/code-server/User/settings.json"]='
{
    "security.workspace.trust.enabled": false,
    "workbench.panel.defaultLocation": "bottom",
    "workbench.colorTheme": "Default Dark Modern",
    "workbench.startupEditor": "none",
    "telemetry.enableTelemetry": false,
    "update.mode": "none"
}
'
  ["$BASE_DIR/.local/share/code-server/workspace.code-workspace"]='
{
    "folders": [
        {
            "path": "'"$BASE_DIR"'"
        }
    ],
    "settings": {
        "security.workspace.trust.untrustedFiles": "open",
        "security.workspace.trust.enabled": true
    }
}
'
  ["$BASE_DIR/.local/share/code-server/coder.json"]='
{
    "query": {
        "folder": "'"$BASE_DIR"'"
    },
    "lastVisited": {
        "url": "'"$BASE_DIR"'/.local/share/code-server/User/workspace.code-workspace",
        "workspace": true
    }
}
'
)

# Set ownership and permissions
OWNER="$USER:$USER"
PERMISSIONS="0640"

# Create directories and write files
for path in "${!files[@]}"; do
  # Create directory if it doesn't exist
  mkdir -p "$(dirname "$path")"

  # Write content to the file
  echo "${files[$path]}" > "$path"

  # Set ownership and permissions
  chown "$OWNER" "$path"
  chmod "$PERMISSIONS" "$path"

  echo "File $path created and configured."
done

echo "All files have been successfully created and configured."

curl -fsSL https://code-server.dev/install.sh | sh

sudo systemctl enable --now code-server@$USER

sudo setcap cap_net_bind_service=+ep /usr/lib/code-server/lib/node

sudo systemctl restart code-server@$USER
