# Role based authorization:
#
# Resource controllers hold actions triggered when Phoenix.Router gets matching
# request. This actions could be "create", "delete", etc.
#
# The role required for triggering an action is deterministic.
# Suppose, a user controller has "create" action, the role required for
# triggering this action is "users/create".
#
# Action names are routes registered by Phoenix to its router.
