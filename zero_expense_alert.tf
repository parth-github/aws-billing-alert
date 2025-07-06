provider "aws" {
  region = "us-east-1" # Billing metrics only available here
}

# add terraform tf cloud  workspace

terraform {
  cloud {
    organization = "smriti-aws"

    workspaces {
      name = "Terraform-AWS-CLI"
    }
  }
}

resource "aws_sns_topic" "billing_alerts" {
  name = "billing-alerts-topic"
}

resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.billing_alerts.arn
  protocol  = "email"
  endpoint  = "smritisnigdhapal@gmail.com" # Replace with your email
}

resource "aws_cloudwatch_metric_alarm" "zero_expense_alarm" {
  alarm_name          = "ZeroExpenseViolation"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = 86400 # 1 day
  statistic           = "Maximum"
  threshold           = 0
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.billing_alerts.arn]

  dimensions = {
    Currency = "INR"
  }
}
