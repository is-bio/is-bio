module FileHelper
  def ensure_directory_exists(filepath)
    dir_path = File.dirname(filepath)
    FileUtils.mkdir_p(dir_path) unless File.directory?(dir_path)
  end

  def remove_target_file(filename)
    if File.exist?(target_filename(filename))
      File.delete(target_filename(filename))
    end
  end

  def target_filename(filename)
    "#{Rails.root}/public/#{filename}"
  end
end
