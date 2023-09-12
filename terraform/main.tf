resource "aws_iam_user" "secrets_sync" {
  name = "vault_secrets_sync_user"
  path = "/"

  tags = {
    tag-key = "vault-secrets-sync-tutorial"
  }
}

resource "aws_iam_access_key" "secrets_sync" {
  user = aws_iam_user.secrets_sync.name
}

output "access_key" {
   value = aws_iam_access_key.secrets_sync.id
}

output "secret_key" {
   value = aws_iam_access_key.secrets_sync.secret
   sensitive = true
}

data "aws_iam_policy_document" "secrets_sync_policy" {
  statement {
    effect    = "Allow"
    actions   = [ "secretsmanager:DescribeSecret",
                "secretsmanager:GetSecretValue",
                "secretsmanager:CreateSecret",
                "secretsmanager:PutSecretValue",
                "secretsmanager:UpdateSecret",
                "secretsmanager:UpdateSecretVersionStage",
                "secretsmanager:DeleteSecret",
                "secretsmanager:RestoreSecret",
                "secretsmanager:TagResource",
                "secretsmanager:UntagResource"]
    resources = ["*"]
  }
}

resource "aws_iam_user_policy" "secrets_sync_policy" {
  name   = "secrets_sync"
  user   = aws_iam_user.secrets_sync.name
  policy = data.aws_iam_policy_document.secrets_sync_policy.json
}