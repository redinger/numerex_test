require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead.
  # Then, you can remove it from this and the functional test.
  include AuthenticatedTestHelper
  fixtures :users,:accounts

  def test_should_create_user
    assert_difference User, :count do
      user = create_user
      assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_password
    assert_no_difference User, :count do
      u = create_user(:password => nil)
      assert u.errors.on(:password)
    end
  end

  def test_should_require_email
    assert_no_difference User, :count do
      u = create_user(:email => nil)
      assert u.errors.on(:email)
    end
  end

  def test_should_reset_password
    users(:dennis).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal users(:dennis), User.authenticate('dennis', 'dennis@ublip.com', 'new password')
  end

  def test_should_not_rehash_password
    users(:dennis).update_attributes(:first_name => 'dennis2')
    assert_equal users(:dennis), User.authenticate('dennis', 'dennis@ublip.com', 'testing')
  end
  
  def test_should_not_authenticate_user
    assert_nil User.authenticate('dennis', 'dennis@ublip.com', 'badpassword')
  end

  def test_should_authenticate_user
    assert_equal users(:dennis), User.authenticate('dennis', 'dennis@ublip.com', 'testing')
  end
  
  def test_should_set_remember_token
    users(:dennis).remember_me
    assert_not_nil users(:dennis).remember_token
    assert_not_nil users(:dennis).remember_token_expires_at
  end

  def test_should_unset_remember_token
    users(:dennis).remember_me
    assert_not_nil users(:dennis).remember_token
    users(:dennis).forget_me
    assert_nil users(:dennis).remember_token
  end
  
  def test_save
    users(:dennis).password = 'testing'
    users(:dennis).save!
  end
  
  def test_edit
    user = users(:dennis)
    assert_equal 'dennis', user.first_name
    assert_equal 'baldwin', user.last_name
    assert_equal User.encrypt('testing', user.salt), user.crypted_password
    user.first_name = 'dennis2'
    user.last_name = 'baldwin2'
    user.password = 'testing123'
    user.save!
  end
  
  def test_generate_token
    user = User.new
    assert_equal("7981aa86aba493c6b4a2c4a2b6cd20b43cccaa9a", user.generate_security_token(1))
  end
  
  def test_change_password
    user = User.new
    user.change_password("qwerty123", "qwerty123")
    assert_equal(user.password, "qwerty123", "qwerty123")
    assert_equal(user.password_confirmation, "qwerty123", "qwerty123")
  end
  
  def test_remember_token
    user = User.new
    pretend_now_is(Time.at(1185490000)) do
      user.remember_me
      assert_equal true, user.remember_token?
    end
    pretend_now_is(Time.at(1185490000+172800)) do #two days later
       assert_equal false, user.remember_token?
    end
  end

  protected
    def create_user(options = {})
      User.create({ :email => 'quire@example.com', :password => 'quire2', :password_confirmation => 'quire2', :first_name => 'Dennis', :last_name => 'Baldwin' }.merge(options))
    end
end
