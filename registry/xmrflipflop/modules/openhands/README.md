---
display_name: OpenHands
description: The self-hosted developer control center for coding agents and automations.
icon: ../../../../.icons/openhands.svg
verified: false
tags: [helper]
---

# OpenHands

This module adds OpenHands to your Coder template.

The simplest usage is:

```tf
module "openhands" {
  count   = data.coder_workspace.me.start_count
  source  = "git::https://github.com/xmrflipflop/coder-registry.git/registry/xmrflipflop/openhands/coder"
  version = "1.0.0"
}
```

# TODO

---

<!-- Add a screencast or screenshot here  put them in .images directory -->

## Examples

### Example 1

Install the Dracula theme from [OpenVSX](https://open-vsx.org/):

```tf
module "openhands" {
  count    = data.coder_workspace.me.start_count
  source   = "git::https://github.com/xmrflipflop/coder-registry.git/registry/xmrflipflop/openhands/coder"
  version  = "1.0.0"
  agent_id = coder_agent.main.id
  install_dir = "/opt/openhands"
}
```

Enter the `<author>.<name>` into the extensions array and code-server will automatically install on start.

### Example 2

Configure VS Code's [settings.json](https://code.visualstudio.com/docs/getstarted/settings#_settingsjson) file:

```tf
module "openhands" {
  count      = data.coder_workspace.me.start_count
  source     = "registry.coder.com/NAMESPACE/openhands/coder"
  version    = "1.0.0"
  agent_id   = coder_agent.main.id
  extensions = ["dracula-theme.theme-dracula"]
  settings = {
    "workbench.colorTheme" = "Dracula"
  }
}
```

### Example 3

Run code-server in the background, don't fetch it from GitHub:

```tf
module "openhands" {
  source   = "registry.coder.com/NAMESPACE/openhands/coder"
  version  = "1.0.0"
  agent_id = coder_agent.main.id
  offline  = true
}
```
