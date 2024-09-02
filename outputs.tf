output "dns_name" {
  value = aws_instance.neo4j_instance.private_dns
}

output "instance_arn" {
  value = aws_instance.neo4j_instance.arn
}

output "root_volume_arn" {
  value = data.aws_ebs_volume.ebs_volume.arn
}
