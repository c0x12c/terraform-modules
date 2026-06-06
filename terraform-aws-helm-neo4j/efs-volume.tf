locals {
  volume_name = "data-neo4j-0"
}

resource "aws_efs_access_point" "neo4j_home" {
  file_system_id = var.efs_id

  posix_user {
    gid = 1000
    uid = 1000
  }

  root_directory {
    creation_info {
      owner_gid   = "1000"
      owner_uid   = "1000"
      permissions = "755"
    }
    path = var.efs_neo4j_access_point
  }

  tags = {
    Name = "${var.helm_release_name}-home"
  }
}

resource "kubernetes_persistent_volume" "neo4j_home" {
  depends_on = [aws_efs_access_point.neo4j_home]

  metadata {
    name = local.volume_name
  }

  spec {
    capacity = {
      storage = var.disk_size
    }

    access_modes       = ["ReadWriteMany"]
    storage_class_name = var.efs_storage_class_name

    persistent_volume_source {
      csi {
        driver        = "efs.csi.aws.com"
        volume_handle = "${var.efs_id}::${aws_efs_access_point.neo4j_home.id}"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "neo4j_home" {
  metadata {
    name      = local.volume_name
    namespace = var.namespace
  }
  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = var.efs_storage_class_name
    resources {
      requests = {
        storage = var.disk_size
      }
    }
    volume_name = kubernetes_persistent_volume.neo4j_home.metadata.0.name
  }
}
