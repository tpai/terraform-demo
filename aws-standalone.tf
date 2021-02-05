resource "aws_cloudfront_distribution" "odhk-data-cf" {
  price_class = "PriceClass_100"
  aliases     = ["data-visualization-portal.data.onedegree.hk"]
  enabled     = true

  origin {
    domain_name = "data-pipeline-portal.data.onedegree.hk"
    origin_id   = aws_elb.odhk_data_pipeline_elb.name

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2", "SSLv3"]
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["TW", "HK"]
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_elb.odhk_data_pipeline_elb.name

    forwarded_values {
      query_string = true
      headers      = ["*"]

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }
}
