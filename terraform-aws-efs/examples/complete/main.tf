module "efs" {
  source = "../../"

  name                       = "example"
  subnet_ids                 = []
  allowed_security_group_ids = []
  vpc_id                     = "vpc-123456"

  efs_access_points = {
    example = {
      posix_user = {
        gid = 1000
        uid = 1000
      }
      root_directory = {
        path = "/var/www/html"
        creation_info = {
          owner_gid   = 1000
          owner_uid   = 1000
          permissions = "755"
        }
      }
    }
  }
}
