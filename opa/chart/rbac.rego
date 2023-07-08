package example

import data.roles
import data.role_bindings

default allow = false

allow {
  user_bindings = role_bindings[input.email][_]
  user_roles = roles[user_bindings]
  user_rules = user_roles[input.path]
  user_rules[_] = input.method
}
