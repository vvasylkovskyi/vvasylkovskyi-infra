resource "aws_iot_thing" "thing" {
  name = var.iot_thing_name
}

resource "aws_iot_policy" "publish_policy" {
  name = var.iot_policy_name
  policy = var.iot_policy
}

resource "aws_iot_certificate" "device_cert" {
  active = true
}

resource "aws_iot_thing_principal_attachment" "attach_cert" {
  thing     = aws_iot_thing.thing.name
  principal = aws_iot_certificate.device_cert.arn
}

resource "aws_iot_policy_attachment" "attach_policy" {
  policy = aws_iot_policy.publish_policy.name
  target = aws_iot_certificate.device_cert.arn
}

data "aws_iot_endpoint" "iot_endpoint" {
  endpoint_type = "iot:Data-ATS"
}
