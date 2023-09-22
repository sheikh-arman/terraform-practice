module "mywebserver" {
  source        = "./modules/webserver"
  key           = file("${path.module}/id_rsa.pub")
  image_id      = "${var.image_id}"
  instance_type = "${var.instance_type}"
  key_name      = "${var.key_name}"
}