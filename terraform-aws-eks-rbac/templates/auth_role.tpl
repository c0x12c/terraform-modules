- groups:
  %{~ if privilege == "admin" ~}
  - "system:masters"
  %{~ endif ~}
  %{~ if privilege == "node" ~}
  - "system:bootstrappers"
  - "system:nodes"
  %{~ endif ~}
  %{~ if privilege == "fargate" ~}
  - "system:bootstrappers"
  - "system:nodes"
  - "system:node-proxier"
  %{~ endif ~}
  %{~ if privilege != "admin" && privilege != "node" && privilege != "fargate" ~}
  - "${privilege}"
  %{~ endif ~}
  "rolearn": "${role_arn}"
  %{~ if profile_type == "fargate" ~}
  "username": "system:node:{{SessionName}}"
  %{~ endif ~}
  %{~ if profile_type == "node"  ~}
  "username": "system:node:{{EC2PrivateDNSName}}"
  %{~ endif ~}
  %{~ if profile_type == "custom"  ~}
  "username": "${role_name}"
  %{~ endif ~}
