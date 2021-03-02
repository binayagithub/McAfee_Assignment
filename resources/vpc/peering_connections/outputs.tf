output "vpc_peering_conn_dev_id"{
    value = "${aws_vpc_peering_connection.vpc_peer_dev.id}"
}