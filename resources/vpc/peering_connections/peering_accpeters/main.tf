resource "aws_vpc_peering_connection_accepter" "peer_accepter" {
    vpc_peering_connection_id = "#{vpc_peering_conn_dev_id_mod}"
    auto_accept               = "${var.auto_accept_peering}"
    
    tags = {
        Name = "${var.vpc_peering_connection_name}"
        Source = "${var.infra_source}"
    }
}