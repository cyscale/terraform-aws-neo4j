data "aws_ebs_volume" "ebs_volume" {
  most_recent = true

  depends_on = [aws_instance.neo4j_instance]

  filter {
    name   = "volume-id"
    values = [aws_instance.neo4j_instance.root_block_device[0].volume_id]
  }
}
