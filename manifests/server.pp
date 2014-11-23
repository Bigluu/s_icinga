class s_icinga::server {

  ## Hiera lookups
  $mysql_root_password    = hiera('s_icinga::server::mysql_root_password')
  $mysql_icinga_user      = hiera('s_icinga::server::mysql_icinga_user')
  $mysql_icinga_hash      = hiera('s_icinga::server::mysql_icinga_hash')
  $mysql_icinga_password  = hiera('s_icinga::server::mysql_icinga_password')
  $mysql_icinga_db        = hiera('s_icinga::server::mysql_icinga_db')
  $apache_serveradmin     = hiera('s_icinga::server::apache_serveradmin')
  $apache_servername      = hiera('s_icinga::server::apache_servername')
  $apache_ssl_cert        = hiera('s_icinga::server::apache_ssl_cert')
  $apache_ssl_key         = hiera('s_icinga::server::apache_ssl_key')
  $apache_ssl_chain       = hiera('s_icinga::server::apache_ssl_chain')
  $users                  = hiera('icinga_users', {})

  create_resources('s_icinga::icinga_users', $users)
  ## Mysql config

  class { 'mysql::server':
    root_password => $mysql_root_password,
    users => {
      "${mysql_icinga_user}@localhost" => {
        ensure           => 'present',
        password_hash    => $mysql_icinga_hash,
      },
    },
    grants => {
      "${mysql_icinga_user}@localhost/${mysql_icinga_db}.*" => {
        ensure      => 'present',
        options     => ['GRANT'],
        privileges  => ['ALL'],
        table       => "${mysql_icinga_db}.*",
        user        => "${mysql_icinga_user}@localhost",
      },
    },
    databases => {
      "${mysql_icinga_db}" => {
        ensure => 'present',
      },
    },
  }

  class { 'mysql::client':
    bindings_enable => true,
  }

  ## Apache config
  class { 'apache':
    mpm_module          => 'prefork',
#    default_mods        => false,
    default_confd_files => false,
#    default_vhost       => true,
    serveradmin         => $apache_serveradmin,
  }
  include apache::mod::php

  apache::vhost { "${apache_servername}":
    priority    => '10',
    port        => '443',
    servername  => "'${apache_servername}'",
    docroot     => '/var/www/html/',
    aliases     => [
      { aliasmatch => '"^/icinga-web/modules/([A-Za-z0-9]+)/resources/styles/([A-Za-z0-9]+\.css)$"',
        path       => '/usr/share/icinga-web/app/modules/$1/pub/styles/$2',
      },
      { aliasmatch => '"^/icinga-web/modules/([A-Za-z0-9]+)/resources/images/([A-Za-z_\-0-9]+\.(?:png|gif|jpg))$"',
        path       => '/usr/share/icinga-web/app/modules/$1/pub/images/$2',
      },
      { scriptalias => '/cgi-bin/icinga2-classicui',
        path        => '/usr/lib/cgi-bin/icinga2-classicui',
      },
      { alias => '/icinga2-classicui/stylesheets',
        path  => '/etc/icinga2/classicui/stylesheets',
      },
      { alias => '/icinga2-classicui',
        path  => '/usr/share/icinga2/classicui',
      },
      { alias => '/icingaweb',
        path  => '/usr/share/icingaweb2/public',
      }
    ],
    directories           => [
      { 'path'            => '^/cgi-bin/icinga2-classicui',
        'provider'        => 'locationmatch',
        'auth_require'    => 'valid-user',
        'custom_fragment' => 'SetEnv ICINGA_CGI_CONFIG /etc/icinga2/classicui/cgi.cfg',
      },
      { 'path'            => '^(?:/usr/share/icinga2/classicui/htdocs|/usr/lib/cgi-bin/icinga2-classicui|/etc/icinga2/classicui/stylesheets)/',
        'provider'        => 'directorymatch',
        'options'         => ['FollowSymLinks'],
        'directoryindex'  => 'index.html',
        'allow_override'  => ['AuthConfig'],
        'auth_name'       => 'Icinga Login',
        'auth_type'       => 'Basic',
        'auth_user_file'  => '/etc/icinga2/classicui/htpasswd.users',
        'auth_require'    => 'valid-user',
      },
      { 'path'            => '/usr/share/icingaweb2/public',
        'provider'        => 'directory',
        'options'         => [ 'SymLinksIfOwnerMatch', ],
        'allow_override'  => 'None',
        'custom_fragment' => 'SetEnv ICINGAWEB_CONFIGDIR "/etc/icingaweb"',
        'sendfile'        => 'Off',
        'rewrites'        => [
          {
            rewrite_base => '/icingaweb/',
            rewrite_cond => ['%{REQUEST_FILENAME} -s [OR]', '%{REQUEST_FILENAME} -l [OR]', '%{REQUEST_FILENAME} -d',],
            rewrite_rule => ['^.*$ - [NC,L]', '^.*$ index.php [NC,L]',],
          },
        ],
      },
    ],
    ssl                  => true,
    ssl_protocol         => 'ALL -SSLv2 -SSLv3',
    ssl_cipher           => 'EDH+CAMELLIA:EDH+aRSA:EECDH+aRSA+AESGCM:EECDH+aRSA+SHA384:EECDH+aRSA+SHA256:EECDH:+CAMELLIA256:+AES256:+CAMELLIA128:+AES128:+SSLv3:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!DSS:!RC4:!SEED:!IDEA:!ECDSA:kEDH:CAMELLIA256-SHA:AES256-SHA:CAMELLIA128-SHA:AES128-SHA',
    ssl_honorcipherorder => 'On',
    ssl_cert             => $apache_ssl_cert,
    ssl_key              => $apache_ssl_key,
    ssl_chain            => $apache_ssl_chain,
  }

  ## Icinga config
  class { 'icinga2::server':
    server_db_type                => 'mysql',
    db_host                       => 'localhost',
    db_port                       => '3306',
    db_name                       => $mysql_icinga_db,
    db_user                       => $mysql_icinga_user,
    db_password                   => $mysql_icinga_password,
    server_install_nagios_plugins => false,
  }

  icinga2::object::idomysqlconnection { 'ido-mysql':
    target_dir       => '/etc/icinga2/features-enabled',
    target_file_name => 'ido-mysql.conf',
    host             => '127.0.0.1',
    port             => '3306',
    user             => $mysql_icinga_user,
    password         => $mysql_icinga_password,
    database         => $mysql_icinga_db,
    categories       => ['DbCatConfig', 'DbCatState', 'DbCatAcknowledgement', 'DbCatComment', 'DbCatDowntime', 'DbCatEventHandler' ],
  }

  Icinga2::Object::Host <<| |>>

  include s_icinga::generic_service_checks
}
