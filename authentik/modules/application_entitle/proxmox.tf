# Create an application entitlement bound to a group
resource "authentik_application" "name" {
  name = "proxmox"
  slug = "proxmox"
}

resource "authentik_application_entitlement" "ent" {
  name        = "test-ent"
  application = authentik_application.name.uuid
}

resource "authentik_group" "group" {
  name = "Infrastructure"
}

resource "authentik_policy_binding" "app-access" {
  target = authentik_application_entitlement.ent.uuid
  group  = authentik_group.group.id
  order  = 0
}