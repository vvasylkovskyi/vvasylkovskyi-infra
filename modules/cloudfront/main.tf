
resource "aws_route53_record" "origin" {
  zone_id = var.route53_zone_id
  name    = "origin.${var.domain_name}"
  type    = "A"
  ttl     = 300

  records = [var.ec2_public_ip]
}

resource "aws_cloudfront_distribution" "cdn" {
  depends_on = [aws_acm_certificate_validation.cert]
  aliases = ["www.${var.domain_name}"]
  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name = aws_route53_record.origin.fqdn
    origin_id   = aws_route53_record.origin.fqdn

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_route53_record.origin.fqdn

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}