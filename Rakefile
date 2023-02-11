task default: [:install]

task :install do
  puts "Installing Text D&D Discord Bot"
  `bundle i`

  `cp text-dnd.service /lib/systemd/system/text-dnd.service`
end

task :uninstall do
  `rm /lib/systemd/system/text-dnd.service`
end
