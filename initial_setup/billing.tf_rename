resource "aws_cloudwatch_metric_alarm" "billing" {
  alarm_name                = "billing-alarm"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "EstimatedCharges"
  namespace                 = "AWS/Billing"
  period                    = "21600" #6h in seconds
  statistic                 = "Maximum"
  threshold                 = "3"
  alarm_actions             = [aws_sns_topic.sns_alert_topic.arn]

  dimensions = {
      Currency = "USD"
  }
}

resource "aws_sns_topic" "sns_alert_topic" {
    name = "billing-alarm-sns-topic"
}


resource "aws_sns_topic_subscription" "email-target" {
  topic_arn = aws_sns_topic.sns_alert_topic.arn
  protocol  = "email"
  endpoint  = "hvoelksen+aws-mgmt@gmail.com"
}

