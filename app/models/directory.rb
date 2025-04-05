class Directory
  def self.published_or_drafts?(filename)
    return false if filename.blank?

    filename.start_with?("published/") || filename.start_with?("drafts/")
  end

  def self.images?(filename)
    return false if filename.blank?

    filename.start_with?("images/")
  end

  def self.files?(filename)
    return false if filename.blank?

    filename.start_with?("files/")
  end
end
