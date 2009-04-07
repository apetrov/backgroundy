namespace :backgroundy do
  desc "Start Backgroundy service"
  task :start=>[:environment] do
    if(File.exist?(Backgroundy.instance.config.pid))
      raise "Error: Backgroundy is already running"
    else  
      result = Process.fork do
        Backgroundy.instance.start
      end
      File.open(Backgroundy.instance.config.pid,"w"){|f|f.write(result)}
    end
  end
  
  task :stop=>[:environment] do
    if(File.exist?(Backgroundy.instance.config.pid))
      pid = File.open(Backgroundy.instance.config.pid){|f|f.read}.to_i
      Process.kill("HUP",pid)
      File.delete(Backgroundy.instance.config.pid)
    else
      puts "Backgroundy not found"
    end
  end
  
  task :restart=>[:stop,:start] do
  end
end