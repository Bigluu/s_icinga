class s_icinga::generic_service_checks {

  icinga2::object::apply_service_to_host { 'apt':
    check_command => 'apt',
    assign_where  => 'host.vars.distro == "Ubuntu"',
    target_dir    => '/etc/icinga2/objects/applys',
  }

  icinga2::object::apply_service_to_host { 'disk':
    check_command => 'disk',
    assign_where  => 'host.vars.os == "Linux"',
    target_dir    => '/etc/icinga2/objects/applys',
  }

  icinga2::object::apply_service_to_host { 'http':
    check_command => 'http',
    assign_where  => 'host.vars.webserver',
    target_dir    => '/etc/icinga2/objects/applys',
  }

  icinga2::object::apply_service_to_host { 'load':
    check_command => 'load',
    assign_where  => 'host.vars.os == "Linux"',
    target_dir    => '/etc/icinga2/objects/applys',
  }

  icinga2::object::apply_service_to_host { 'procs':
    check_command => 'procs',
    assign_where  => 'host.vars.os == "Linux"',
    target_dir    => '/etc/icinga2/objects/applys',
  }
  
  icinga2::object::apply_service_to_host { 'ssh':
    check_command => 'ssh',
    assign_where  => 'host.vars.os == "Linux"',
    target_dir    => '/etc/icinga2/objects/applys',
  }
  
  icinga2::object::apply_service_to_host { 'swap':
    check_command => 'swap',
    assign_where  => 'host.vars.os == "Linux"',
    target_dir    => '/etc/icinga2/objects/applys',
  }

  icinga2::object::apply_service_to_host { 'users':
    check_command => 'users',
    assign_where  => 'host.vars.os == "Linux"',
    target_dir    => '/etc/icinga2/objects/applys',
  }
  
}
