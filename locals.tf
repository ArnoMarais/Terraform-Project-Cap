locals {
  learner_subnet_file = jsondecode(file("${path.root}/learner_subnets.json"))

  # Facilitator's JSON has a typo: this entry is for marais (the user).
  learner = local.learner_subnet_file.learners["marias-a"]

}