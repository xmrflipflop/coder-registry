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
  count  = data.coder_workspace.me.start_count
  source = "git::https://github.com/xmrflipflop/coder-registry.git//registry/xmrflipflop/modules/openhands"
}
```

---

<!-- Add a screencast or screenshot here  put them in .images directory -->

## Examples

### Example 1

Specify repository `url` and `branch` to fetch OpenHands from
Specify application `port` number
Specify install to `install_dir`
Install with a `pre_install_script` that blocks until prior dependency unit is complete.

```tf
module "openhands" {
  count              = data.coder_workspace.me.start_count
  source             = "git::https://github.com/xmrflipflop/coder-registry.git//registry/xmrflipflop/modules/openhands"
  agent_id           = coder_agent.main.id
  url                = "https://github.com/xmrflipflop/openhands-full-stack.git"
  branch             = "main"
  install_dir        = "/opt/openhands"
  port               = 9000
  pre_install_script = <<-EOT
    #!/bin/bash
    trap 'coder exp sync complete pre-openhands' EXIT
    coder exp sync want pre-openhands <prior dependency unit>
    coder exp sync start pre-openhands
  EOT
}
```
