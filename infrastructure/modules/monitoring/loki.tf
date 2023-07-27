/****************************************************************************************************************************
                                          Creating S3 Bucket For Loki-logs
Reference: https://rtfm.co.ua/en/grafana-loki-architecture-and-running-in-kubernetes-with-aws-s3-storage-and-boltdb-shipper/                
*****************************************************************************************************************************/
resource "random_integer" "random_integer" {
  min                     = 1000
  max                     = 99999
}

resource "aws_s3_bucket" "loki_s3_bucket" {
  bucket                  = "${local.loki_logs_bucket}-${random_integer.random_integer.result}"
  depends_on              = [kubernetes_namespace.monitoring]
  tags   = {    
    workload              = "monitoring" 
  } 
}

resource "aws_s3_bucket_server_side_encryption_configuration" "loki_s3_bucket" {
  bucket                  = aws_s3_bucket.loki_s3_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm       = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "loki_s3_bucket" {
  bucket                  = aws_s3_bucket.loki_s3_bucket.id
  rule {
    id                    = "move_events_to_ia"
    status                = "Enabled"
    transition {
      days                = 30
      storage_class       = "STANDARD_IA"
    }
    expiration {
      days                = 365
    }
  }
}

resource "aws_s3_bucket_public_access_block" "loki_s3_policy" {
  bucket                  = aws_s3_bucket.loki_s3_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

/****************************************************************
                      Installing Loki
  https://github.com/grafana/loki/tree/main/production/helm/loki 
*****************************************************************/
resource "helm_release" "loki" {
  name                    = "loki"
  namespace               = "monitoring"
  chart                   = "loki"
  repository              = "https://grafana.github.io/helm-charts"
  version                 = "5.5.2"
  atomic                  = true
  timeout                 = 1200  
  values                  =    [<<EOT
loki:
  auth_enabled: false
  limits_config:
    max_entries_limit_per_query: 10000000
    max_query_length : 8640h 
  commonConfig:
    path_prefix: /var/loki
    replication_factor: 1
  storage:
    bucketNames:
      chunks: ${aws_s3_bucket.loki_s3_bucket.id}
    type: s3
  schema_config:
    configs:
    - from: "2022-01-11"
      index:
        period: 24h
        prefix: loki_index_
      store: boltdb-shipper
      object_store: s3
      schema: v12
      chunks:
        period: 24h
  storage_config:
    aws:
      s3: s3://${var.aws_region}/${aws_s3_bucket.loki_s3_bucket.id}
      insecure: false
      s3forcepathstyle: true
    boltdb_shipper:
      active_index_directory: /var/loki/index
      shared_store: s3
      cache_ttl: 24h  
      cache_location: /var/loki/cache  
  rulerConfig:
    storage:
      type: local
      local:
        directory: /var/loki/rules
  compactor:
    working_directory: /var/loki/compactor
    shared_store: s3
    compaction_interval: 5m
    retention_enabled: true
    retention_delete_delay: 2400h
    apply_retention_interval: 1h
    retention_delete_worker_count: 500
test:
  enabled: false
monitoring:
  dashboards:
    enabled: false
  rules:
    enabled: false
    alerting: false
  serviceMonitor:
    enabled: false
    metricsInstance:
      enabled: false
  selfMonitoring:
    enabled: false
    grafanaAgent:
      installOperator: false
  lokiCanary:
    enabled: false
write:
  replicas: 2
  resources: 
    requests:
     cpu: 10m
     memory: 100Mi
  persistence:
    size: 5Gi
    storageClassName: "gp3-encrypted"
read:
  replicas: 2
  resources: 
    requests:
     cpu: 10m
     memory: 100Mi
backend:
  replicas: 2
  resources: 
    requests:
     cpu: 10m
     memory: 100Mi
  persistence:
    size: 5Gi
    storageClassName: "gp3-encrypted"
                              EOT
                        ]
}
