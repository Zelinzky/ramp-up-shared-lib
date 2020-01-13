output "alb_dns_name" {
  value       = aws_lb.movie_api_elb.dns_name
  description = "The domain name of the load balancer"
}

output "user_data" {
  value = aws_launch_configuration.movie_api_instance.user_data
}