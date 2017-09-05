module Puppet::Parser::Functions
  newfunction(:get_packages_for_upgrade, :arity => 1, :type => :rvalue, :doc => <<-EOS
Return a hash of packages (for specified source.list) that can be upgraded. All
packages have by default ensure => latest. This function is applicable only on Debian based OS.

Example:
  get_packages_for_upgrade('/etc/apt/source.list.d/')

Output example for upgradable package list (in one line string):
  Inst ntp [1:4.2.6.p5+dfsg-3ubuntu2.14.04.8] (2:4.2.6.p5+dfsg-3~u14.04+mos1 mos9.0:mos9.0-proposed [amd64])\n
  Inst ntpdate [1:4.2.6.p5+dfsg-3ubuntu2.14.04.8] (2:4.2.6.p5+dfsg-3~u14.04+mos1 mos9.0:mos9.0-proposed [amd64])\n
  Conf ntp (2:4.2.6.p5+dfsg-3~u14.04+mos1 mos9.0:mos9.0-proposed [amd64])\n
  Conf ntpdate (2:4.2.6.p5+dfsg-3~u14.04+mos1 mos9.0:mos9.0-proposed [amd64])\n

Function output example:
  { 'ntp' => { 'ensure' => 'latest'}, 'ntpdate' => { 'ensure' => 'latest' } }
EOS
  ) do |args|
    return {} if Facter.value(:osfamily) != 'Debian'
    errmsg = "get_packages_for_upgrade($apt_source_list_path)"
    source_list = args[0]
    raise(Puppet::ParseError, "#{errmsg}: 1st argument should be a string") unless source_list.is_a?(String)
    raise(Puppet::ParseError, "#{errmsg}: $apt_source_list_path should exists") unless file_exists(source_list)

##################


    cmd_update = "apt-get update"
    apt_get_update = system(cmd_update)
    if apt_get_update

        repofile_list = Dir.glob("#{source_list}*")

        repo_in_list = []
        upgrade_packages = {}

        repo_fh = File.open(repofile_list[0], "r")
        repo_fh.each_line do |line|
            if line[0] != '#'
                repo_in_list = line.split
                puts "!!! RETURN REPO_IN_LIST !!! #{repo_in_list}"
            end
        end
        repo_fh.close


        repo_cache_name = Dir.glob("/var/lib/apt/lists/#{repo_in_list[1].split('http://')[1].gsub('/','_')}*_#{repo_in_list[2]}_*_Packages")
        puts "!!!!???? REPO_CACHE_NAME: #{repo_cache_name}"
        for every_file in repo_cache_name
            repo_cache_fh = File.open(every_file, "r")
            repo_cache_fh.each_line do |line|
                if line.include? "Package:"
                    pckg_name = line.split[1]
                    puts "!!! pckg_name: #{pckg_name}"
                    upgrade_packages[pckg_name] =  { 'ensure' => 'latest' }
                end
            end

            repo_cache_fh.close
        end


        puts ""
        puts "!!! RETURN upgrade_packages !!! #{upgrade_packages}"
        puts ""

        packages_to_upgrade = upgrade_packages



        ##packages_to_upgrade = Hash.new

        ##package_list_common_out = %x(apt-get --just-print -o Dir::etc::sourcelist='-' -o Dir::Etc::sourceparts='#{source_list}' dist-upgrade -qq)
        # take only lines which describe installation step
        ##package_list = package_list_common_out.split("\n").select { |line| line =~ /^Inst\b/ }
        ##package_list.each do |package|
          ##package_name = package.split(' ')[1]
          ##packages_to_upgrade[package_name] = { 'ensure' => 'latest' }
        ##end
        return packages_to_upgrade
    end
    end
end

# method is added to stub call for tests
def file_exists(path)
  File.exist?(path)
end
