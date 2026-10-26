moved {
  from = aws_iam_policy.secrets
  to   = aws_iam_policy.secrets[0]
}

moved {
  from = aws_iam_policy.ssm
  to   = aws_iam_policy.ssm[0]
}

moved {
  from = aws_iam_role_policy_attachment.ecs_task_execution_role_secrets_policy_attachment
  to   = aws_iam_role_policy_attachment.ecs_task_execution_role_secrets_policy_attachment[0]
}

moved {
  from = aws_iam_role_policy_attachment.ecs_task_execution_role_ssm_policy_attachment
  to   = aws_iam_role_policy_attachment.ecs_task_execution_role_ssm_policy_attachment[0]
}
