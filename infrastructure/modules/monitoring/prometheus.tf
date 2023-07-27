/****************************************
      Creating monitoring namespace
*****************************************/
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name            = "monitoring"
  }
}

/*********************************************************************************************************************
                                                    Installing Prometheus
  https://github.com/prometheus-community/helm-charts/tree/kube-prometheus-stack-45.28.1/charts/kube-prometheus-stack
**********************************************************************************************************************/
resource "helm_release" "prometheus" {
  depends_on        = [kubernetes_namespace.monitoring] 
  name              = "prometheus"
  namespace         = "monitoring"
  chart             = "kube-prometheus-stack"
  repository        = "https://prometheus-community.github.io/helm-charts"
  version           = "45.28.1"
  atomic            = true
  timeout           = 1200  
  values            = [ <<EOT
namespaceOverride: "monitoring"
fullnameOverride: "prometheus"
defaultRules:
  rules:
    alertmanager: true
    etcd: true
    configReloaders: true
    general: true
    k8s: true
    kubeApiserver: true
    kubeApiserverAvailability: true
    kubeApiserverError: true
    kubeApiserverBurnrate: true
    kubeApiserverHistogram: true
    kubeApiserverSlos: true
    kubeControllerManager: true
    kubelet: true
    kubeProxy: true
    kubePrometheusGeneral: true
    kubePrometheusNodeAlerting: true
    kubePrometheusNodeRecording: true
    kubernetesAbsent: true
    kubernetesApps: true
    kubernetesResources: true
    kubernetesStorage: true
    kubernetesSystem: true
    kubeScheduler: false
    kubeSchedulerAlerting: false
    kubeSchedulerRecording: false
    kubeStateMetrics: true
    network: true
    node: true
    nodeExporterAlerting: true
    nodeExporterRecording: true
    prometheus: true
    prometheusOperator: true

global:
  rbac:
    create: true
    pspEnabled: true

alertmanager:
  config:
    global:
      http_config:
        follow_redirects: true

grafana:
  enabled: false
  forceDeployDashboards: true

  serviceMonitor:
    enabled: true
    selfMonitor: true
    metricRelabelings: []

kubeApiServer:
  enabled: true
  tlsConfig:
    serverName: kubernetes
    insecureSkipVerify: true
    metricRelabelings: []

kubelet:
  enabled: true
  serviceMonitor:  
    cAdvisorMetricRelabelings: []

kubeControllerManager:
  enabled: false

kubeEtcd:
  enabled: true
  service:
    enabled: true
    port: 2379
    targetPort: 2379

kube-state-metrics:
  extraArgs:
    - --metric-labels-allowlist=pods=[*],deployments=[*],services=[*],nodes=[*]
    # - --metric-labels-allowlist=[*]

nodeExporter:
  enabled: true
  resources:
    limits:
      cpu: 50m
      memory: 200Mi
    requests:
      cpu: 10m
      memory: 40Mi

prometheusOperator:
  enabled: true
  prometheusConfigReloader:
    resources:
      requests:
        cpu: 10m
        memory: 50Mi
      limits:
        cpu: 100m
        memory: 500Mi

prometheus:
  enabled: true

  prometheusSpec:
    alertingEndpoints:
    - name: prometheus-alertmanager
      namespace: monitoring
      port: 9093
      scheme: http
      pathPrefix: /
      apiVersion: v2

    probeSelector:
      matchLabels:
        app: blackbox-exporter

    retention: 60d

    walCompression: false

    storageSpec:
     volumeClaimTemplate:
       spec:
         storageClassName: gp3-encrypted
         accessModes: ["ReadWriteOnce"]
         resources:
           requests:
             storage: 50Gi

    additionalScrapeConfigs:
    - job_name: kubernetes-pods
      kubernetes_sd_configs:
      - role: pod
      relabel_configs:
      - source_labels: [__meta_kubernetes_namespace]
        action: drop
        regex: monitoring
      - source_labels:
        - __meta_kubernetes_pod_annotation_prometheus_io_scrape
        action: keep
        regex: true
      - source_labels:
        - __meta_kubernetes_pod_annotation_prometheus_io_path
        action: replace
        target_label: __metrics_path__
        regex: (.+)
      - source_labels:
        - __address__
        - __meta_kubernetes_pod_annotation_prometheus_io_port
        action: replace
        regex: (.+):(?:\d+);(\d+)
        replacement: ${1}:${2}
        target_label: __address__
      - action: labelmap
        regex: __meta_kubernetes_pod_label_(.+)

    - job_name: 'kubernetes-service-endpoints'
      kubernetes_sd_configs:
      - role: endpoints
      relabel_configs:
      - source_labels: [__meta_kubernetes_namespace]
        action: drop
        regex: monitoring
      - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scrape]
        action: keep
        regex: true
      - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scheme]
        action: replace
        target_label: __scheme__
        regex: (http|https)
      - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_path]
        action: replace
        target_label: __metrics_path__
        regex: (.+)
      - source_labels: [__address__, __meta_kubernetes_service_annotation_prometheus_io_port]
        action: replace
        target_label: __address__
        regex: ([^:]+)(?::\d+)?;(\d+)
        replacement: $1:$2

    - job_name: 'envoy-stats'
      metrics_path: /stats/prometheus
      kubernetes_sd_configs:
      - role: pod
      relabel_configs:
      - source_labels: [__meta_kubernetes_pod_container_port_name]
        action: keep
        regex: '.*-envoy-prom'
EOT
                        ]
}


/**************************************************************************************************
                            Installing Blackbox-Exporter For Prometheus
  https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-blackbox-exporter
***************************************************************************************************/
resource "helm_release" "blackbox-exporter" {
  depends_on        = [helm_release.prometheus]
  name              = "blackbox-exporter"
  namespace         = "monitoring"
  chart             = "prometheus-blackbox-exporter"
  repository        = "https://prometheus-community.github.io/helm-charts"
  version           = "7.8.0"
  atomic            = true
  timeout           = 1200
  values            = [<<EOT
namespaceOverride: "monitoring"
config:
  modules:
    http_2xx:
      prober: http
      timeout: 5s
      http:
        valid_http_versions: ["HTTP/1.1", "HTTP/2.0"]
        valid_status_codes: [200] 
        method: GET
        follow_redirects: true
        preferred_ip_protocol: "ip4"

resources:
  requests:
    cpu: 10m
    memory: 50Mi
                              EOT
                        ]
}
