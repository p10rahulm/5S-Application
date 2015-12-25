module UsersHelper
# Returns the Gravatar for the given user.
  def gravatar_for(user, options = {size:80})
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    size = options[:size]
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: user.name, class: "gravatar")
  end

  def avatar_for(user, options = {size:80})

    if user.avatar?    then
      if options[:size]==50 then
        image_tag(user.avatar.url(:smavatar), alt: user.name, class: "avatar")
      else

        image_tag(user.avatar.url(:thumbavatar), alt: user.name, class: "avatar")
      end

    else
      gravatar_for(user,options)
    end
  end

end
