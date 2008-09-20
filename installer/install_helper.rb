require 'fileutils'

module RAMF
  module InstallHelper
    def file_in_app(*args)
      File.join(args.unshift(RAILS_ROOT))
    end
    
    def file_in_installer(*args)
      File.join(args.unshift(File.dirname(__FILE__)))
    end
    
    def create_file_unless_exists!(path_under_rails, template=nil, verbose = true)
      template ||= file_in_installer(File.basename(path_under_rails))
      print("Creating file: #{path_under_rails}.....") if verbose
      if !File.exist?(file = file_in_app(path_under_rails))
        FileUtils.mkdir_p(File.dirname(file))
        FileUtils.copy_file(template, file, false)
        print("[OK]\n") if verbose
      else
        print("[Exists]\n") if verbose
      end
    end
    
    
    def remove_file!(path_under_rails,remove_dir = true, verbose = true)
      print("Removing file: #{path_under_rails}.....") if verbose
      if File.exist?(file = file_in_app(path_under_rails))
        FileUtils.rm(file)
        print("[OK]\n") if verbose
        remove_dir_if_empty!(File.dirname(file), verbose) if remove_dir
      else
        print("[Doesn't Exist]\n") if verbose
      end
    end
    
    def remove_dir_if_empty!(dir, verbose)
      print("Removing directory: #{dir}......") if verbose
      if Dir[File.join(dir,"*")].empty?
        FileUtils.rm_r(dir)
        print("[OK]\n") if verbose
      else
        print("[Non Empty]\n") if verbose
      end
    end
    
  end
end