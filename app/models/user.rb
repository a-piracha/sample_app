class User < ApplicationRecord

    attr_accessor :remember_token, :activation_token, :reset_token
    # has_many :microposts, dependent: :destroy

    # has_many :active_relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy

    has_many :microposts, dependent: :destroy

    has_many :active_relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
    has_many :passive_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy
    has_many :following, through: :active_relationships, source: :followed
    has_many :followers, through: :passive_relationships, source: :follower

    # Chat
    has_many :sent_messages, class_name: "Chat", foreign_key: "sender_id"    
    has_many :recieved_messages, class_name: "Chat", foreign_key: "reciever_id"
    has_many :recieved, through: :sent_messages, source: :reciever
    has_many :sent, through: :recieved_messages, source: :sender


    before_save :downcase_email
    before_create :create_activation_digest

    validates :name, presence: true, length: { maximum: 50 }
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :email, presence: true, length: { maximum: 255 },
    format: { with: VALID_EMAIL_REGEX }, uniqueness: true
    has_secure_password
    validates :password, presence: true, length: { minimum: 6 },
    allow_nil: true
    
    # Returns the hash digest of the given string.
    def User.digest(string)
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
        # binding.pry
        BCrypt::Password.create(string, cost: cost)
    end

    # Returns true if the given token matches the digest.
    def authenticated?(attribute, token)
        digest = send("#{attribute}_digest")
        return false if digest.nil?
        BCrypt::Password.new(digest).is_password?(token)
    end
    
    # Returns a random token.
    def User.new_token
        SecureRandom.urlsafe_base64
        # BCrypt::Password.create(SecureRandom.urlsafe_base64)
    end

    # Remembers a user in the database for use in persistent sessions.
    def remember
        self.remember_token = User.new_token
        update_attribute(:remember_digest, User.digest(remember_token))
        remember_digest
    end

    # Returns a session token to prevent session hijacking.
    # We reuse the remember digest for convenience.
    def session_token
        remember_digest || remember
    end

    def forget
        update_attribute(:remember_digest, nil)
    end

    # Activates an account.
    def activate
        # update_attribute(:activated, true)
        # update_attribute(:activated_at, Time.zone.now)
        update_columns(activated: true, activated_at: Time.zone.now)
    end
    # Sends activation email.
    def send_activation_email
        UserMailer.account_activation(self).deliver_now
    end

    # Sets the password reset attributes.
    def create_reset_digest
        self.reset_token = User.new_token
        update_attribute(:reset_digest, User.digest(reset_token))
        update_attribute(:reset_sent_at, Time.zone.now)
        # update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
    end

    # Sends password reset email.
    def send_password_reset_email
      UserMailer.password_reset(self).deliver_now
    end


    # Returns true if a password reset has expired.
    # "Password reset sent earlier than two hours ago."

    def password_reset_expired?
        reset_sent_at < 2.hours.ago
    end
    # # Defines a proto-feed.
    # # See "Following users" for the full implementation.
    # def feed
    #     Micropost.where("user_id = ?", id)
    # end

    # Returns a user's status feed.
    # def feed
    #     Micropost.where("user_id IN (?) OR user_id = ?",
    #     following_ids, id)
    # end

    def feed
        # Micropost.where("user_id IN (:following_ids) OR user_id = :user_id", following_ids: following_ids, user_id: id)

        # following_ids = "SELECT followed_id FROM relationships WHERE follower_id = :user_id"
        # Micropost.where("user_id IN (#{following_ids}) OR user_id = :user_id", user_id: id)

        following_ids = "SELECT followed_id FROM relationships WHERE follower_id = :user_id"
        Micropost.where("user_id IN (#{following_ids}) OR user_id = :user_id", user_id: id).includes(:user, image_attachment: :blob)
    end

    # Message sent
    def sent_msg(other_user, message_content)
        return if self == other_user 
        Chat.create(sender_id: self.id, reciever_id: other_user.id, message: message_content)
    end

    # Follows a user.
    def follow(other_user)
        following << other_user unless self == other_user
    end

    # Unfollows a user.
    def unfollow(other_user)
        following.delete(other_user)
    end

    # Returns true if the current user is following the other user.
    def following?(other_user)
        following.include?(other_user)
    end
    private

    # Converts email to all lowercase.
    def downcase_email
        self.email = email.downcase
    end
    
    # Creates and assigns the activation token and digest.
    def create_activation_digest
        self.activation_token = User.new_token
        self.activation_digest = User.digest(activation_token)
    end
end