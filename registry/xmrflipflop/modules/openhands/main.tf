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

  # base64 so arbitrary shell content passes safely through templatefile()
  encoded_pre_install_script = var.pre_install_script != null ? base64encode(var.pre_install_script) : ""
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

variable "git_ref" {
  type        = string
  description = "The OpenHands Git branch, tag, or commit SHA to install."
  default     = "main"
}

variable "git_repository_url" {
  type        = string
  description = "The OpenHands Git repository URL to install."
  default     = "https://github.com/xmrflipflop/openhands-full-stack.git"

  validation {
    condition     = can(regex("^(https?://|git@)", var.git_repository_url))
    error_message = "URL must be a valid Git repository URL beginning with https://, http://, or git@."
  }
}

variable "port" {
  type        = number
  description = "The port on which to run OpenHands."
  default     = 9000

  validation {
    condition     = var.port >= 1024 && var.port <= 49151
    error_message = "Port must be between 1024 and 49151."
  }
}

variable "pre_install_script" {
  type        = string
  description = "Custom script to run before installing <your-tool>. Useful for dependency ordering between modules (e.g. waiting for git-clone to complete)."
  default     = null
}

# Run scripts
resource "coder_script" "openhands_up" {
  agent_id           = var.agent_id
  display_name       = "OpenHands"
  icon               = local.icon_url
  run_on_start       = true
  start_blocks_login = true
  run_on_stop        = false

  script = templatefile("${path.module}/start.sh.tftpl", {
    _install_dir : var.install_dir,
    _checkout_url : var.git_repository_url,
    _checkout_branch : var.git_ref,
    _ingress_port : var.port,
    _pre_install_script = local.encoded_pre_install_script,
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
    echo "Stopping OpenHands in ${var.install_dir}"
    # graceful stop so apps get SIGINT before the container dies
      cd "${var.install_dir}" && just serve --production --background --stop || true
      echo "Done"
  EOT
}

resource "coder_app" "openhands" {
  agent_id     = var.agent_id
  slug         = "openhands"
  display_name = "OpenHands"
  url          = "http://localhost:${var.port}"
  icon         = local.icon_url
  subdomain    = true
  share        = "owner"
  order        = var.order

  healthcheck {
    url       = "http://localhost:${var.port}/health"
    interval  = 5
    threshold = 6
  }
}

