module "eks-access-entry" {
  source = "../"

  cluster_name = "example-cluster"
  access_entries = [
    /*
      Role for cluster administrators with full access to the EKS cluster
     */
    {
      principal_arn = "arn:aws:iam::<account-id>:role/aws-reserved/sso.amazonaws.com/us-west-2/SpartanAdministratorAccess"
      policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
      kubernetes_groups = [
        "system:masters"
      ]
    },
    /*
      Role for cluster developers with view-only access to the EKS cluster
     */
    {
      principal_arn = "arn:aws:iam::<account-id>:role/aws-reserved/sso.amazonaws.com/us-west-2/SpartanPowerUserAccess"
      policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterViewPolicy"
    },
    /*
      Role for managing access to a specific namespace in the EKS cluster
     */
    {
      principal_arn = "arn:aws:iam::<account-id>:role/aws-reserved/sso.amazonaws.com/us-west-2/SpartanAdministratorAccess"
      policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
      access_type   = "namespace"
      namespaces    = ["service-platform"]
    },
    /*
      Pre-existing role used for CI/CD pipelines within GitHub Actions
     */
    {
      principal_arn = "arn:aws:iam::<account-id>:role/github-actions/role-terraform-ops"
      policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
    }
  ]
}
