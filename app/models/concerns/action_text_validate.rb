module ActionTextValidate
  extend ActiveSupport::Concern

  # 以下の定数（サイズ制限）を各モデルで定義する
  # MAX_MEGA_BYTES = 5
  # MAX_ATTACHMENT_BYTE_SIZE = MAX_MEGA_BYTES * (1_024 ** 2)

  def create_validate_attachment(attr_name, max_mega_bytes)
    define_method("validate_#{attr_name}_attachment_byte_size") do
      send(attr_name).body.attachables.grep(ActiveStorage::Blob).each do |attachable|
        byte_size = attachable.byte_size
        max_attachment_byte_size = max_mega_bytes * (1_024 ** 2)
        if byte_size > max_attachment_byte_size
          errors.add(
            :base,
            :attachment_byte_size_is_too_large,
            filename: attachable.filename.to_s,
            max_attachment_mega_byte_size: max_mega_bytes,
            bytes: byte_size,
            max_bytes: max_attachment_byte_size
          )
        end
      end
    end
  end
end
