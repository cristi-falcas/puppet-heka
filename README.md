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

If applicable, this section should have a brief description of the technology
the module integrates with and what that integration enables. This section
should answer the questions: "What does this module *do*?" and "Why would I use
it?"

If your module has a range of functionality (installation, configuration,
management, etc.) this is the time to mention it.

## Setup

### Beginning with heka

Install the heka server:

    include heka

Install plugins:

    heka::plugin::dashboard { 'Dashboard': }

    heka::plugin::tcpinput { 'RsyslogDecoder':
	    port                 => 1514,
	    decoder              => 'RsyslogDecoder',
	    send_decode_failures => true,
	    splitter             => 'NullSplitter',
	    use_tls              => false,
	    net                  => 'tcp4',
	}
	
	heka::decoder::rsyslogdecoder { 'RsyslogDecoder': template => '<%PRI%>%TIMESTAMP:::date-rfc3339% %HOSTNAME% %syslogtag%%msg%\n' }

Configure a heka server:

	heka::plugin::tcpinput { 'heka_server':
	    port    => 5565,
	    send_decode_failures      => true,
	    use_tls => true,
	    tls_cert_file             => "${::settings::ssldir}/certs/${::clientcert}.pem",
	    tls_key_file              => "${::settings::ssldir}/private_keys/${::clientcert}.pem",
	    tls_client_cafile         => "${::settings::ssldir}/certs/ca.pem",
	    tls_client_auth           => 'RequireAndVerifyClientCert',
	    tls_prefer_server_ciphers => true,
	    tls_min_version           => 'TLS11',
	    net                       => 'tcp4',
	}

On the server, we don't want to have the tcpinput plugin enabled:

    Heka::Plugin::Tcpoutput <| title == 'to_heka_server' |> {
	    ensure => absent
	}

Print all messages to stdout:

    heka::encoder::rstencoder {'RstEncoder': }

    heka::plugin::logoutput {'debug':
        message_matcher => "Type == 'heka.counter-output'",
        encoder         => 'RstEncoder',
    }

## Development

* Fork the project
* Commit and push until you are happy with your contribution
* Send a pull request with a description of your changes
