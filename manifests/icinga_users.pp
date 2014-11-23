define s_icinga::icinga_users (
  $ensure,
  $display_name,
  $email = undef,
  $pager = undef,
  $groups = [ "icingaadmins" ],
  $target_dir = '/etc/icinga2/objects/users/',
) {
  $username = $title

  if $ensure == 'present' {
    icinga2::object::user { "${username}":
      display_name => $display_name,
      email        => $email,
      groups       => $groups,
      pager        => $pager,
      target_dir   => '/etc/icinga2/objects/users/',
    }
  }
}
