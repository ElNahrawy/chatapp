class Application < ApplicationRecord
    has_many :chats
    validates_presence_of :name
end
