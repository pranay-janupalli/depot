require "test_helper"

class OrderMailerTest < ActionMailer::TestCase
  test "recieved" do
    mail = OrderMailer.recieved
    assert_equal "Recieved", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
