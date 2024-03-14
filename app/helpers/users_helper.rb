module UsersHelper
# Returns the Gravatar for the given user.
    def gravatar_for(user, options = { size: 80 })
        size = options[:size]
        gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
        gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
        image_tag(gravatar_url, alt: user.name, class: "gravatar")
    end
end


# module CarsHelper
#     def gravatar_for(car,size: 100 )
#         gravatar_id = Digest::MD5::hexdigest(car.user_email.downcase) if car.user_email.present?
#         gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
#         image_tag(gravatar_url, alt: car.car_user, class: "gravatar")
#     end
#   end
  