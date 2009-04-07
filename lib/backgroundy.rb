require "ostruct"
require "thread"
require "drb"
require "singleton.rb"

class Backgroundy
  include Singleton
  
  def config
    @config||=OpenStruct.new
  end
  
  def prepare(&block)
    @config||=OpenStruct.new
    @config.drb=OpenStruct.new(:host=>"localhost",:port=>4000,:protocol=>"druby")
    @config.service = BackService
    @config.logger = Logger.new("log/backgroundy.log")
    @config.pid="log/backgroundy.pid"
    yield(@config)
  end
  
  def start
    @config.service.instance.init
    DRb.start_service(uri,@config.service.instance)
    @config.logger.info("Service #{config.service.name} started on #{uri}")
    DRb.thread.join
  end
  
  def uri
    "#{@config.drb.protocol}://#{@config.drb.host}:#{@config.drb.port}"
  end
  
  def self.client
    DRbObject.new(nil,Backgroundy.instance.uri)
  end
end

class BackService
  include Singleton
  
  def run_in_bg(&block)
    Thread.new{
      yield()
    }
  end
  
  def thread_safe!(&block)
    semaphore.synchronize {
      yield()
    }
  end
  
  def config
    Backgroundy.instance.config
  end
  
  def logger
    Backgroundy.instance.config.logger
  end
  
  def semaphore
    @semaphore||= Mutex.new
  end
  
  def init()
    puts "Starting"
  end
end

