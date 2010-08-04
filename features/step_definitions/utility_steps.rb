When /^I clean up$/ do |table|
  # table is a | Test List      | group    |
  table.hashes.each do |hash|
    case hash[:exchangetype]
      when 'group'
        group = DistributionGroup.find(hash[:name])
        group.delete
      when 'contact'
        contact = ExchangeUser.new :login => hash[:name], :alias => hash[:name], :type => 'MailContact'
        contact.destroy
      when 'user'
        user = ExchangeUser.find(hash[:name])
        user.destroy
    end
  end
end