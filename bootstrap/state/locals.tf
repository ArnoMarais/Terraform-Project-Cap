locals {
  # DISABLED for now: qa and prod are out of scope. Restore as toset(["dev", "qa", "prod"]) when in scope.
  environments = toset(["dev"])
  # environments = toset(["dev","qa","prod"])
}