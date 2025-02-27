module AresMUSH
  class FS3Attribute < Ohm::Model
    include ObjectModel
    include LearnableAbility
    
    reference :character, "AresMUSH::Character"
    attribute :name
    attribute :rating, :type => DataType::Integer, :default => 0
    
    index :name
    
    def print_rating
      case rating
      when 0
        return ""
      when 1
        return "%xg@%xn"
      when 2
        return "%xg@%xy@%xn"
      when 3
        return "%xg@%xy@%xr@%xn"
      when 4
        return "%xg@%xy@%xr@%xb@%xn"
      when 5
        return "%xy@@@@@%xn"
      end
    end
    
    def rating_name
      case rating
      when 0 
        return ""
      when 1
        return t('fs3skills.poor_rating')
      when 2
        return t('fs3skills.average_rating')
      when 3
        return t('fs3skills.attr_good_rating')
      when 4
        return t('fs3skills.attr_exceptional_rating')
      when 5
        return t('fs3skills.attr_god_rating')
      end
    end
  end
end