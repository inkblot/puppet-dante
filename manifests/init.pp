# ex: syntax=puppet si ts=4 sw=4 et

class dante (
    $socks_port = '1080',
    $client_range = '127.0.0.1/32',
    $target_range = '0.0.0.0/0',
    $internal_iface,
    $external_iface,
    $dante_package,
    $dante_service,
) {
    File {
        ensure  => present,
        owner   => 'root',
        group   => 'root',
    }

    package { $dante_package:
        ensure => latest,
    }

    file { '/etc/danted.conf':
        mode    => '644',
        content => template('dante/danted.conf.erb'),
        require => Package[$dante_package],
    }

    file { '/usr/local/bin/dante-server-status':
        mode    => '0755',
        source  => 'puppet:///modules/dante/dante-server-status',
        before  => Service[$dante_service],
    }

    service { $dante_service:
        ensure    => running,
        provider  => debian,
        hasstatus => false,
        status    => '/usr/local/bin/dante-server-status',
        subscribe => File['/etc/danted.conf'],
    }
}
