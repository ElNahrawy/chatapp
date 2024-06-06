class Message < ApplicationRecord
    belongs_to :chat
    #searchkick
    
    # include Elasticsearch::Model
    # include Elasticsearch::Model::Callbacks
    # # index_name Rails.application.class.parent_name.underscore
    # # document_type self.name.downcase
    # settings index: { number_of_shards: 1 } do
    #     mapping dynamic: false do
    #       indexes :message_body, type: 'text', analyzer: 'english'
    #     end
    # end

    # def self.search(query)
    #     params = {
    #       query: {
    #         multi_match: {
    #           query: query,
    #           fields: ['message_body'],
    #           fuzziness: "AUTO"
    #         }
    #       }
    #     }
    #     self.__elasticsearch__.search(params).records.to_a
    #     #self.__elasticsearch__.search(params)
    # end
end
