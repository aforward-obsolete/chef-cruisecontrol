
name = "cruisecontrol-bin-#{node[:cruisecontrol][:version]}"
src_dir = "#{node[:cruisecontrol][:install_dir]}/#{name}"

package "zip"
package "unzip"
package "openjdk-6-jdk"

cookbook_file "/tmp/#{name}.zip" do
  source "#{name}.zip"
  mode 0755
  owner "root"
  group "root"
end

execute "unzip-cruisecontrol" do
  command "unzip /tmp/#{name}.zip -d #{node[:cruisecontrol][:install_dir]}"
  not_if { File.directory?(src_dir) }
end

link "/bin/java" do
  to "#{node[:cruisecontrol][:java_home]}/bin/java"
end

template "#{src_dir}/config.xml" do
  owner "root"
  group "root"
  mode 0700
  source 'cruisecontrol_config.xml.erb'
end

execute "start cruisecontrol" do
  cwd src_dir
  command "./cruisecontrol.sh"
  only_if { `ps -ef | grep \`cat #{src_dir}/cc.pid\` | grep -v grep`.strip.empty? }
end