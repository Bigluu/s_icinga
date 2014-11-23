class s_icinga::nrpe {


  ## Hiera lookups

    $allowed_hosts  = hiera('s_icinga::nrpe::allowed_hosts')
    $vars           = hiera('s_icinga::nrpe::vars',{})

    class { 'icinga2::nrpe':
        nrpe_allowed_hosts => $allowed_hosts,
    }

    $default_vars     = {
      os              => 'Linux',
      virtual_machine => 'true',
      distro          => $::operatingsystem,
    }

    $real_vars = merge($default_vars,$vars)

    @@icinga2::object::host { $::fqdn:
      display_name      => $::fqdn,
      ipv4_address      => $::ipaddress,
      ipv6_address      => $::ipaddress6,
      # groups          => ['linux_servers', 'mysql_servers'],
      vars              => $real_vars,
      target_dir => '/etc/icinga2/objects/hosts',
      target_file_name => "${fqdn}.conf"
    }
}
