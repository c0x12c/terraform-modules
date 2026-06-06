resource "aws_efs_access_point" "jenkins_home" {
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
    path = var.efs_jenkins_access_point
  }

  tags = {
    Name = "jenkins-home"
  }
}

resource "kubernetes_persistent_volume" "jenkins_home" {
  depends_on = [aws_efs_access_point.jenkins_home]

  metadata {
    name = "jenkins-home-pv"
  }

  spec {
    capacity = {
      storage = "30Gi"
    }

    access_modes       = ["ReadWriteMany"]
    storage_class_name = var.efs_storage_class_name

    persistent_volume_source {
      csi {
        driver        = "efs.csi.aws.com"
        volume_handle = "${var.efs_id}::${aws_efs_access_point.jenkins_home.id}"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "jenkins_home" {
  metadata {
    name      = "jenkins-home-pvc"
    namespace = "jenkins"
  }
  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = var.efs_storage_class_name
    resources {
      requests = {
        storage = var.efs_volume_size
      }
    }
    volume_name = kubernetes_persistent_volume.jenkins_home.metadata.0.name
  }
}
