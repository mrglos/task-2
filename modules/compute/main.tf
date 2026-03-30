# 1. Dedicated Service Account for instances (good practice for security and permissions management)
resource "google_service_account" "web_sa" {
  account_id   = "${var.app_name}-sa"
  display_name = "Service Account for Web App"
  project      = var.project_id
}

# 2. Instance template
resource "google_compute_instance_template" "web_template" {
  name_prefix  = "${var.app_name}-template-"
  project      = var.project_id
  machine_type = var.machine_type
  tags         = ["web-app"] # Tag, allows traffic from Firewall (Health Checks)

  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network    = var.network_id
    subnetwork = var.subnet_id
    # 'access_config' intentinally ommitted - instances won't have public IP
  }

  service_account {
    email  = google_service_account.web_sa.email
    scopes = ["cloud-platform"]
  }

  # Starting script: installs Nginx and replaces default page with one that displays host name (for testing)
  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    echo "<h1>Hello InPost! I am running on: $(hostname)</h1>" > /var/www/html/index.html
    systemctl restart nginx
  EOF

  lifecycle {
    create_before_destroy = true
  }
}

# 3. Health Check for Load Balancer and Autohealer
resource "google_compute_health_check" "web_hc" {
  name                = "${var.app_name}-hc"
  project             = var.project_id
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2

  http_health_check {
    port         = 80
    request_path = "/"
  }
}

# 4. Regional instances group (HA - instances in regions a, b, c)
resource "google_compute_region_instance_group_manager" "web_mig" {
  name               = "${var.app_name}-mig"
  project            = var.project_id
  region             = var.region
  base_instance_name = var.app_name

  version {
    instance_template = google_compute_instance_template.web_template.id
  }

  # Named port, required for Load Balancer to know which port to send traffic to
  named_port {
    name = "http"
    port = 80
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.web_hc.id
    initial_delay_sec = 120
  }
}

# 5. Autoscaler (based on CPU)
resource "google_compute_region_autoscaler" "web_autoscaler" {
  name    = "${var.app_name}-autoscaler"
  project = var.project_id
  region  = var.region
  target  = google_compute_region_instance_group_manager.web_mig.id

  autoscaling_policy {
    max_replicas    = 5
    min_replicas    = 2
    cooldown_period = 60

    cpu_utilization {
      target = 0.6
    }
  }
}

# --- Global HTTP Load Balancer configuration ---

resource "google_compute_backend_service" "web_backend" {
  name                  = "${var.app_name}-backend"
  project               = var.project_id
  port_name             = "http"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL"
  health_checks         = [google_compute_health_check.web_hc.id]

  backend {
    group           = google_compute_region_instance_group_manager.web_mig.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

resource "google_compute_url_map" "web_url_map" {
  name            = "${var.app_name}-url-map"
  project         = var.project_id
  default_service = google_compute_backend_service.web_backend.id
}

resource "google_compute_target_http_proxy" "web_http_proxy" {
  name    = "${var.app_name}-http-proxy"
  project = var.project_id
  url_map = google_compute_url_map.web_url_map.id
}

# Load Balancer's Public IP address
resource "google_compute_global_forwarding_rule" "web_forwarding_rule" {
  name                  = "${var.app_name}-forwarding-rule"
  project               = var.project_id
  target                = google_compute_target_http_proxy.web_http_proxy.id
  port_range            = "80"
  load_balancing_scheme = "EXTERNAL"
}
