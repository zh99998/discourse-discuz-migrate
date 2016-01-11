# name: discuz-migrate
# about: Migrate Discuz Ucenter user passwords to discourse.
# version: 0.1
# authors: zh99998 <zh99998@gmail.com>

require 'digest/md5'

after_initialize do
  User.class_eval do
    alias old_hash_password hash_password
    def hash_password(password, salt)
      if salt.size == 6
        Digest::MD5.hexdigest Digest::MD5.hexdigest(password) + salt
      else
        old_hash_password(password, salt)
      end
    end
  end
end
