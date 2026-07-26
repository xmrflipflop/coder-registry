terraform {
  required_version = ">= 1.0"

  required_providers {
    coder = {
      source  = "coder/coder"
      version = ">= 2.5"
    }
  }
}

locals {
  # A built-in icon like "/icon/code.svg" or a full URL of icon
  # :open_hands:
  icon_url = "/emojis/1f450.png"
}

# Input variables
variable "agent_id" {
  type        = string
  description = "The ID of a Coder agent."
}

variable "install_dir" {
  description = "Directory to install the application"
  type        = string
  default     = "/opt/openhands"
}

variable "order" {
  type        = number
  description = "The order determines the position of app in the UI presentation. The lowest order is shown first and apps with equal order are sorted by name (ascending order)."
  default     = null
}

# Run scripts
resource "coder_script" "openhands_up" {
  agent_id           = var.agent_id
  display_name       = "OpenHands Start"
  icon               = local.icon_url
  run_on_start       = true
  start_blocks_login = true
  run_on_stop        = false

  script = templatefile("${path.module}/start.sh.tftpl", {
    _install_dir : var.install_dir,
    _checkout_url : data.coder_parameter.url.value,
    _checkout_branch : data.coder_parameter.branch.value,
    _ingress_port : data.coder_parameter.port.value,
  })
}

resource "coder_script" "openhands_down" {
  agent_id     = var.agent_id
  display_name = "OpenHands Shutdown"
  icon         = local.icon_url
  run_on_start = false
  run_on_stop  = true

  script = <<-EOT
    #!/usr/bin/env bash
    # graceful stop so apps get SIGINT before the container dies
    pm2 kill || true
  EOT
}

resource "coder_app" "openhands" {
  agent_id     = var.agent_id
  slug         = "openhands"
  display_name = "OpenHands"
  url          = "http://localhost:${data.coder_parameter.port.value}"
  icon         = local.icon_url
  subdomain    = true
  share        = "owner"
  order        = var.order

  healthcheck {
    url       = "http://localhost:${data.coder_parameter.port.value}/health"
    interval  = 5
    threshold = 6
  }
}

# Workspace parameters
data "coder_parameter" "branch" {
  name         = "branch"
  display_name = "OpenHands Git branch or ref"
  description  = "The Git branch, tag, or commit SHA to install."
  type         = "string"
  default      = "main"
  mutable      = true
}

data "coder_parameter" "url" {
  name         = "url"
  display_name = "OpenHands Git repository URL"
  description  = "Git repository URL to install."
  type         = "string"
  default      = "https://github.com/xmrflipflop/openhands-full-stack.git"
  mutable      = true

  validation {
    regex = "^(https?://|git@)"
    error = "URL must be a valid Git repository URL beginning with https://, http://, or git@."
  }
}

data "coder_parameter" "port" {
  name         = "port"
  display_name = "Application port"
  description  = "The port to run the application on."
  type         = "number"
  default      = 9999
  mutable      = true

  validation {
    min   = 1024
    max   = 49151
    error = "Port must be between {min} and {max}."
  }
}