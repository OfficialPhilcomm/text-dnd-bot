require "strong_yaml"

module TextDnD
  class Config
    include StrongYAML

    file "config.yml"

    schema do
      group :discord do
        integer :application_id
        string :public_key
        string :token
      end
    end
  end
end

TextDnD::Config.create_or_load
