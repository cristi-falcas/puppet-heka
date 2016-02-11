# heka
[![Build Status](https://travis-ci.org/cristifalcas/puppet-heka.png?branch=master)](https://travis-ci.org/cristifalcas/puppet-heka)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with heka](#setup)
    * [Beginning with heka](#beginning-with-heka)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

Heka is a tool for collecting and collating data from a number of different sources, performing "in-flight"
processing of collected data, and delivering the results to any number of destinations for further analysis.

## Module Description

Current version only works with heka 0.10.

If applicable, this section should have a brief description of the technology
the module integrates with and what that integration enables. This section
should answer the questions: "What does this module *do*?" and "Why would I use
it?"

If your module has a range of functionality (installation, configuration,
management, etc.) this is the time to mention it.

## Setup

### Beginning with heka

Install a heka server:
	
	    include heka
	
Forward rsyslog to heka:
	
	  class { 'rsyslog':
	    package_status  => 'latest',
	    purge_rsyslog_d => true,
	    preserve_fqdn   => true,
	  }
	
	  class { 'rsyslog::client':
	    log_local                 => true,
	    listen_localhost          => false,
	    high_precision_timestamps => true,
	    spool_size                => '1g',
	    server                    => 'localhost',
	    port                      => 1514,
	    remote_servers            => false,
	    remote_type               => 'tcp',
	    remote_forward_format     => 'RSYSLOG_ForwardFormat',
	    rate_limit_burst          => 2000,
	    rate_limit_interval       => 0,
	  }
	  
	  include heka
	  
	  heka::inputs::tcpinput { 'FromRsyslog':
	    address              => ':1514',
	    decoder              => 'RsyslogDecoder',
	    splitter             => 'split_on_newline',
	    send_decode_failures => true,
	    use_tls              => false,
	    net                  => 'tcp4',
	    keep_alive           => true,
	  }
	
	  heka::splitters::tokensplitter { 'split_on_newline': }
	
	
Forward all logs to a central logging server:
	
	  heka::outputs::tcpoutput { 'SendToServer':
	    message_matcher           => 'TRUE',
	    address                   => 'heka_server.company.net:5565',
	    use_tls                   => true,
	    tls_cert_file             => "${::settings::ssldir}/certs/${::clientcert}.pem",
	    tls_key_file              => "${::settings::ssldir}/private_keys/${::clientcert}.pem",
	    tls_client_cafile         => "${::settings::ssldir}/certs/ca.pem",
	    tls_client_auth           => 'RequireAndVerifyClientCert',
	    tls_prefer_server_ciphers => true,
	    tls_min_version           => 'TLS11',
	  }
	
	
Configure a heka server:
	
	  include heka
	
	  heka::inputs::tcpinput { 'heka_server':
	    address                   => ':5565',
	    send_decode_failures      => true,
	    use_tls                   => true,
	    tls_cert_file             => "${::settings::ssldir}/certs/${::clientcert}.pem",
	    tls_key_file              => "${::settings::ssldir}/private_keys/${::clientcert}.pem",
	    tls_client_cafile         => "${::settings::ssldir}/certs/ca.pem",
	    tls_client_auth           => 'RequireAndVerifyClientCert',
	    tls_prefer_server_ciphers => true,
	    tls_min_version           => 'TLS11',
	    net     => 'tcp4',
	  }
	
	  # don't forward to any server from here
	  Heka::Outputs::Tcpoutput <| title == 'SendToServer' |> {
	    ensure => 'absent',
	  }
	
	
Send logs to an elasticsearch instance:
	
	  heka::outputs::elasticsearchoutput { 'es':
	    message_matcher   => 'TRUE',
	    encoder           => 'ESJsonEncoder',
	    flush_count       => 10000,
	    server            => 'http://localhost:9200',
	  }
	
	  heka::encoder::esjsonencoder { 'ESJsonEncoder':
	    es_index_from_timestamp => true,
	  }
	
	
Install various plugins:
	
	  heka::outputs::dashboardoutput { 'Dashboard': }
	
	
Print all messages to stdout:
	
	  # debug
	  heka::outputs::logoutput { 'stdout_debug':
	    message_matcher => 'TRUE',
	    encoder         => 'rstencoder'
	  }
	
	  heka::encoder::rstencoder { 'rstencoder': }
	
	
Collect nginx logs:
	
	  heka::inputs::logstreamerinput { 'logstreamerinput':
	    decoder       => 'nginx_access',
	    log_directory => '/var/log/nginx',
	    file_match => 'access\.log(-)?(?P<Index>\d+)?(.gz)?',
	    priority => ["^Index"]
	  }
	
	  heka::decoder::nginxaccesslogdecoder { 'nginx_access':
	    log_format           => '$remote_addr - [$time_local] "$request" $status $body_bytes_sent $request_time "$http_referer" "$http_user_agent" "$cookie_JSESSIONID" ',
	    type                 => 'combined',
	    payload_keep         => true,
	    user_agent_keep      => true,
	    user_agent_transform => true
	  }
	  

## Development

* Fork the project
* Commit and push until you are happy with your contribution
* Send a pull request with a description of your changes
