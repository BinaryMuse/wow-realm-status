module Realmstatus
  module Helpers
    def link_to(text, url)
      "<a href='#{url}' />#{text}</a>"
    end

    def proper_realm_type(type)
      case type
      when "pvp"
        "PvP"
      when "pve"
        "PvE"
      when "rp"
        "RP"
      when "rppvp"
        "RP PvP"
      end
    end

    def proper_realm_pop(pop)
      case pop
      when "high"
        "High"
      when "medium"
        "Medium"
      when "low"
        "Low"
      else
        pop
      end
    end

    def realm_matches(realm, text)
      realm["slug"].start_with?(text) || realm["name"].start_with?(text)
    end
  end
end
