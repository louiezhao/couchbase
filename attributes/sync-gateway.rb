#
# Cookbook Name:: couchbase
# Attributes:: server
#
# Author:: Julian C. Dunn (<jdunn@opscode.com>)
# Copyright (C) 2012, SecondMarket Labs, LLC.
# Copyright (C) 2013, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

package_machine = node['kernel']['machine'] == "x86_64" ? "x86_64" : "x86"

default['couchbase']['sync-gateway']['edition'] = "community"
default['couchbase']['sync-gateway']['version'] = "1.0.0"
default['couchbase']['sync-gateway']['package_file'] = "couchbase-sync-gateway-#{node['couchbase']['sync-gateway']['edition']}_#{node['couchbase']['sync-gateway']['version']}_#{package_machine}.rpm"
default['couchbase']['sync-gateway']['package_base_url'] = "http://packages.couchbase.com/releases/couchbase-sync-gateway/#{node['couchbase']['sync-gateway']['version']}"
default['couchbase']['sync-gateway']['package_full_url'] = "#{node['couchbase']['sync-gateway']['package_base_url']}/#{node['couchbase']['sync-gateway']['package_file']}"
default['couchbase']['sync-gateway']['install_dir'] = "/opt/couchbase-sync-gateway"
default['couchbase']['sync-gateway']['log_dir'] = File.join(node['couchbase']['sync-gateway']['install_dir'],"var","lib","couchbase","logs")
default['couchbase']['sync-gateway']['conf_dir'] = File.join(node['couchbase']['sync-gateway']['install_dir'],"etc")
default['couchbase']['sync-gateway']['allow_unsigned_packages'] = true
default['couchbase']['sync-gateway']['server_url'] = nil