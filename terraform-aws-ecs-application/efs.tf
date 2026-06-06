module "efs" {
  source  = "c0x12c/efs/aws"
  version = "~> 0.1.78"

  count = var.persistent_volume != null ? 1 : 0

  name       = var.name
  subnet_ids = var.subnet_ids
  efs_access_points = {
    (var.name) = {
      posix_user = {
        gid = var.persistent_volume.gid
        uid = var.persistent_volume.uid
      }
      root_directory = {
        path = var.persistent_volume.path
        creation_info = {
          owner_gid   = var.persistent_volume.gid
          owner_uid   = var.persistent_volume.uid
          permissions = "755"
        }
      }
    }
  }
  allowed_security_group_ids = compact([try(aws_security_group.this[0].id, null)])
  vpc_id                     = var.vpc_id
}
