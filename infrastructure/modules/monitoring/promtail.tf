/****************************************************************
                      Installing Promtail
  https://github.com/grafana/helm-charts/tree/main/charts/promtail  
*****************************************************************/
resource "helm_release" "promtail" {
  depends_on        = [helm_release.loki]
  name              = "promtail"
  namespace         = "monitoring"
  chart             = "promtail"
  repository        = "https://grafana.github.io/helm-charts"
  version           = "6.11.2"
  atomic            = true
  timeout           = 1200  
  values            =  [<<EOT
podAnnotations:
 prometheus.io/scrape: "true"
 prometheus.io/port: "http-metrics"

tolerations:
  - operator: Exists
    effect: NoExecute
  - operator: Exists
    effect: NoSchedule
    
config:
  clients:
    - url: http://loki-gateway/loki/api/v1/push
  snippets:
    pipelineStages:
      - docker: {}
    extraScrapeConfigs: |
      - job_name: journal
        journal:
          path: /var/log/journal
          max_age: 12h
          labels:
            job: systemd-journal
        relabel_configs:
          - source_labels: ['__journal__systemd_unit']
            target_label: 'unit'
          - source_labels: ['__journal__hostname']
            target_label: 'hostname' 

extraVolumes:
  - name: journal
    hostPath:
      path: /var/log/journal
 
extraVolumeMounts:
  - name: journal
    mountPath: /var/log/journal
    readOnly: true
          
resources:
 requests:
   cpu: 50m
   memory: 50Mi
                              EOT
                        ]
}
