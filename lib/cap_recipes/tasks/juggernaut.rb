Capistrano::Configuration.instance(true).load do
  set :juggernaut_config, "#{current_path}/config/juggernaut.yml"
  set :juggernaut_pid, "#{current_path}/tmp/pids/juggernaut.pid"
  set :juggernaut_log, "#{current_path}/log/juggernaut.log"
  
  namespace :juggernaut do            
    # ===============================================================
    # PROCESS MANAGEMENT
    # ===============================================================  
    
    desc "Starts the juggernaut push server"
    task :start, :role => :app do
      puts "Starting juggernaut push server"
      sudo "#{sudo} juggernaut -c #{juggernaut_config} -d --pid #{juggernaut_pid} --log #{juggernaut_log}"
    end
    
    desc "Stops the juggernaut push server"
    task :stop, :role => :app do
      puts "Stopping juggernaut push server"
      sudo "#{sudo} juggernaut -c #{juggernaut_config} -k * --pid #{juggernaut_pid} --log #{juggernaut_log}" 
    end
    
    desc "Restarts the juggernaut push server"
    task :restart, :role => :app do
      juggernaut.stop
      juggernaut.start
    end  
    
    # ===============================================================
    # FILE MANAGEMENT
    # ===============================================================  
    
    desc "Copies the shared/config/juggernaut yaml to release/config/"
    task :copy_config, :role => :app do
      sudo "cp #{shared_path}/config/juggernaut.yml #{release_path}/config/"
    end
    
    desc "Displays the juggernaut log from the server"
    task :tail, :role => :app do
      stream "tail -f #{shared_path}/log/juggernaut.log" 
    end
  end
  
  # ===============================================================
  # TASK CALLBACKS
  # ===============================================================  
  
  after "deploy:update_code", "juggernaut:copy_config" # copy juggernaut.yml on update code
  after "deploy:restart"    , "juggernaut:restart"     # restart juggernaut on app restart
end