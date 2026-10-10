output "wordpress_ip" {
  value = aws_instance.wordpress.public_ip
}

output "db_endpoint" {
  value = aws_db_instance.mysql.endpoint
}

output "wordpress_url" {
  value = "http://${aws_instance.wordpress.public_ip}"
}
