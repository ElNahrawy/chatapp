class Message < ApplicationRecord
    belongs_to :chat
    searchkick
end
