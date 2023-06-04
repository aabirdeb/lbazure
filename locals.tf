locals {
  #lbname = "${var.client_name}-${var.environment}-${var.location}-lb"

  lbname = "${var.client_name}_${var.role}_${var.environment}_lb_${var.location}"

  alert_conv = "${var.environment}-lb"

  lb_bepool = flatten([
    for lb_key, lb in var.loadbalancers : [
      for be_key, be in lb.bepools : {
        lb_key = lb_key
        be_key = be_key
        lb_id  = azurerm_lb.this[lb_key].id
      }
    ]
  ])

  lb_bepoolvm = flatten([
    for lb_key, lb in var.loadbalancers : [
      for be_key, be in lb.bepools : [
        for vm_key, vm in be.vms : {
          lb_key     = lb_key
          be_key     = be_key
          vm_key     = vm_key
          lb_id      = azurerm_lb.this[lb_key].id
          network_id = vm.network_id
          ipname     = vm.ipname
        }
      ]
    ]
  ])

  lb_probes = flatten([
    for lb_key, lb in var.loadbalancers : [
      for probe_key, probe in lb.probes : {
        lb_key              = lb_key
        probe_key           = probe_key
        lb_id               = azurerm_lb.this[lb_key].id
        port                = probe.port
        protocol            = probe.protocol
        interval_in_seconds = probe.interval_in_seconds
      }
    ]
  ])


  lb_rules = flatten([
    for lb_key, lb in var.loadbalancers : [
      for ruleslb_key, rulelb in lb.rules : {
        lb_key                         = lb_key
        ruleslb_key                    = ruleslb_key
        lb_id                          = azurerm_lb.this[lb_key].id
        protocol                       = rulelb.protocol
        backend_port                   = rulelb.backend_port
        frontend_ip_configuration_name = rulelb.frontend_ip_configuration_name
        frontend_port                  = rulelb.frontend_port
        backend_address_pool_name      = rulelb.backend_address_pool_name
        probe_name                     = rulelb.probe_name
        enable_floating_ip             = rulelb.enable_floating_ip
        loadbalancer_id                = azurerm_lb.this[lb_key].id
      }
    ]
  ])

  lb_alert = flatten([
    for lb_key, lb in var.loadbalancers : [
      for alert in lb.lbalert : {
        lb_name           = lb_key
        alert_name        = alert.name
        alert_description = alert.description
        alert_metric_name = alert.metric_name
        alert_severity    = alert.severity
        alert_enabled     = alert.enabled
        alert_aggregation = alert.aggregation
        alert_operator    = alert.operator
        alert_threshold   = alert.threshold
        alert_actiongroup = alert.actiongroup
        lb_id             = azurerm_lb.this[lb_key].id
      }

    ]
  ])



  lb_dimension = flatten([
    for lb_key, lb in var.loadbalancers : [
      for alert in lb.lbalert : [
        for dimension in alert.dimensions : {
          lb_name            = lb_key
          alert_name         = alert.name
          alert_actiongroup  = alert.actiongroup
          dimension_name     = dimension.name
          dimension_operator = dimension.operator
          dimension_values   = dimension.values
        }
      ]
    ]
  ])


  
env_tags = {
    "role"        = var.role
    "rg_name"     = var.resource_group_name
    "environment" = var.environment
    "owner"       = var.owner
    "vendor"      = var.vendor
    "application" = var.client_name
    "creator"     = var.creator
  }
  lb_tags = "${merge(local.env_tags, var.tags)}"

}
