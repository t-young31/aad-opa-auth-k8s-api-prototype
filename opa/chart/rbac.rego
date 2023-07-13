package rbac

import data.roles
import data.role_bindings

import future.keywords.contains
import future.keywords.if
import future.keywords.in

default allow := false

allow if {
  user_bindings = role_bindings[input.email][_]
  user_roles = roles[user_bindings]
  user_rules = user_roles[input.path]
  user_rules[_] = input.method
}

allow if "admin" in role_bindings[input.email]

allow if input.path = "/authorize"
