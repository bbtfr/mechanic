module WeixinMediaLoader
  extend ActiveSupport::Concern

  module ClassMethods
    def weixin_media_loader field
      field_writer = :"#{field}="
      media_id_reader = :"#{field}_media_id"
      media_id_writer = :"#{field}_media_id="

      attr_reader media_id_reader
      define_method media_id_writer do |media_id|
        if media_id.present?
          media_file = Weixin::Client.download_media_url(media_id)
          send field_writer, media_file
        end
      end
    end

    def weixin_media_loaders *fields
      fields.each do |field|
        weixin_media_loader field
      end
    end
  end
end
