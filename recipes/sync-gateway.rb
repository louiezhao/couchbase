#
# Cookbook Name:: couchbase
# Recipe:: server
#
# Copyright 2012, getaroom
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

remote_file File.join(Chef::Config[:file_cache_path], node['couchbase']['sync-gateway']['package_file']) do
  source node['couchbase']['sync-gateway']['package_full_url']
  action :create_if_missing
end

yum_package File.join(Chef::Config[:file_cache_path], node['couchbase']['sync-gateway']['package_file']) do
  options node['couchbase']['sync-gateway']['allow_unsigned_packages'] == true ? "--nogpgcheck" : ""
end

directory node['couchbase']['sync-gateway']['log_dir'] do
  owner "couchbase"
  group "couchbase"
  mode 0755
  recursive true
end

directory node['couchbase']['sync-gateway']['conf_dir'] do
  owner "couchbase"
  group "couchbase"
  mode 0755
  recursive true
end

template "sync_gateway.json" do
  path File.join(node['couchbase']['sync-gateway']['conf_dir'], "sync_gateway.json")
  source "sync_gateway.json.erb"
  owner "couchbase"
  group "couchbase"
  mode "0755"
end

ruby_block "block_until_operational" do
  block do
    Chef::Log.info "Waiting until Couchbase Sync Gateway is listening on port 4984"
    until CouchbaseHelper.service_listening?(4984) do
      sleep 1
      Chef::Log.debug(".")
    end

    Chef::Log.info "Waiting until the Couchbase Sync Gateway Admin API is responding"
    test_url = URI.parse("http://localhost:4985")
    until CouchbaseHelper.endpoint_responding?(test_url) do
      sleep 1
      Chef::Log.debug(".")
    end
  end
  action :nothing
end

service "sync-gateway" do
  supports :restart => true, :start => true, :stop => true, :status => true
  action :nothing
end

template "sync-gateway" do
  path "/etc/init.d/sync-gateway"
  source "sync-gateway.erb"
  owner "root"
  group "root"
  mode "0755"
  
  if node['couchbase']['sync-gateway']['server_url']
    notifies :enable, "service[sync-gateway]", :immediately
    notifies :restart, "service[sync-gateway]", :immediately
    notifies :create, "ruby_block[block_until_operational]", :immediately
  end
end
