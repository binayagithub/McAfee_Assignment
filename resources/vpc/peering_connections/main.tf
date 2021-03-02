resource "aws_vpc_peering_connection" "vpc_peer_dev" {
    vpc_id        = "${var.requester_vpc_id}"
    peer_vpc_id   = "${var.accepcter_vpc_id}"
    peer_region = "${var.peer_region}"
    
    tags = {
        Name = "${var.vpc_peering_connection_name}"
        Source = "${var.infra_source}"
    }
}
