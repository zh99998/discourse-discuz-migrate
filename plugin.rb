# name: discuz-migrate
# about: Migrate Discuz Ucenter user passwords to discourse.
# version: 0.1
# authors: zh99998 <zh99998@gmail.com>

require 'digest/md5'

after_initialize do

  # Ucenter password

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

  # old url

  require_dependency 'application_controller'
  class ::DiscuzController < ::ApplicationController
    skip_before_filter :check_xhr
    def redirect
      if params[:pid] and p = PostCustomField.find_by_name_and_value('import_id', params[:pid])
        return redirect_to p.post.url, status: :moved_permanently
      end
      if params[:tid] and t = TopicCustomField.find_by_name_and_value('import_id', params[:tid])
        return redirect_to t.topic.url, status: :moved_permanently
      end
      if params[:fid] and c = CategoryCustomField.find_by_name_and_value('import_id', params[:fid])
        return redirect_to c.category.url, status: :moved_permanently
      end
      if params[:uid] and u = UserCustomField.find_by_name_and_value('import_id', params[:uid])
        return redirect_to user_path(u.user.username), status: :moved_permanently
      end
      if params[:username] and u = UserCustomField.find_by_name_and_value('import_username', params[:username])
        return redirect_to user_path(u.user.username), status: :moved_permanently
      end
      redirect_to '/'
    end
  end
  Discourse::Application.routes.prepend do
    get "index.php" => "discuz#redirect"
    get "forum.php" => "discuz#redirect"
    get "home.php" => "discuz#redirect"
    get "viewthread.php" => "discuz#redirect"
    get "forumdisplay.php" => "discuz#redirect"
    get "redirect.php" => "discuz#redirect"
  end
end
