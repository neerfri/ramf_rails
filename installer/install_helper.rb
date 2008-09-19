module RAMF
  module InstallHelper
    def file_in_app(*args)
      File.join(args.unshift(RAILS_ROOT))
    end
    
    def file_in_installer(*args)
      File.join(args.unshift(File.dirname(__FILE__)))
    end
  end
end