require 'test_helper'

class AvatarUploadTest < ActionDispatch::IntegrationTest
  include SessionsHelper
  def setup
    @user = users(:rahul)
    @user2 = users(:hombalappa)
  end


  def file
    @avatar ||= File.open(File.expand_path( '../../fixtures/rails.png', __FILE__))
  end

  def uploaded_file_object(klass, attribute, file, content_type = 'png')

    filename = File.basename(file.path)
    klass_label = klass.to_s.underscore

    ActionDispatch::Http::UploadedFile.new(
        tempfile: file,
        filename: filename,
        head: %Q{Content-Disposition: form-data; name="#{klass_label}[#{attribute}]"; filename="#{filename}"},
        content_type: content_type
    )
  end
  def test_update

    get edit_user_path(@user)
    @test_path=request.url
    assert_equal session[:forwarding_url], @test_path
    log_in_as(@user)
    assert_redirected_to edit_user_path(@user)
    name = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), user: { name: name,
                                    email: email,
                                    password: "",
                                    password_confirmation: "" }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name, @user.name
    assert_equal email, @user.email
    @picture_path = 'test/fixtures/rails.png'
    @picture = fixture_file_upload(@picture_path, 'image/png')
    name = "Foo Barz"
    email = "foo@barz.com"
    patch user_path(@user), user: { name: name,
                                    email: email,
                                    avatar: @picture,
                                    password: "",
                                    password_confirmation: "" }

    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name, @user.name
    assert_equal email, @user.email
    # binding.pry
    assert_equal File.basename(@picture_path), File.basename(@user.avatar.path)
    @picture = uploaded_file_object(User, :avatar, file)
    name = "Foo Barzed"
    email = "foo@barzed.com"
    patch user_path(@user), user: { name: name,
                                    email: email,
                                    avatar: @picture,
                                    password: "",
                                    password_confirmation: "" }


    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name, @user.name
    assert_equal email, @user.email
    # binding.pry
    assert_equal @picture.original_filename, File.basename(@user.avatar.path)

    log_out
    #non admin user
    log_in_as(@user2)
    @picture_path = 'test/fixtures/rails.png'
    @picture = fixture_file_upload(@picture_path, 'image/png')
    name = "Foo Barzho"
    email = "foo@barzho.com"
    patch user_path(@user2), user: { name: name,
                                    email: email,
                                    avatar: @picture,
                                    password: "",
                                    password_confirmation: "" }

    assert_not flash.empty?
    assert_redirected_to @user2
    @user2.reload
    assert_equal name, @user2.name
    assert_equal email, @user2.email
    assert_equal File.basename(@picture_path), File.basename(@user2.avatar.path)
    @picture2 = uploaded_file_object(User, :avatar, file)
    name = "Foo Barzedho"
    email = "foo@barzedho.com"
    patch user_path(@user2), user: { name: name,
                                    email: email,
                                    avatar: @picture,
                                    password: "",
                                    password_confirmation: "" }


    assert_not flash.empty?
    assert_redirected_to @user2
    @user2.reload
    assert_equal name, @user2.name
    assert_equal email, @user2.email
    # binding.pry
    assert_equal @picture.original_filename, File.basename(@user2.avatar.path)

  end
end
