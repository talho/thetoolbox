module WhiteListsHelper
  def is_domain?(text)
    text.split("@").size == 1
  end

  def is_email?(text)
    text.split("@").size > 1
  end
end
