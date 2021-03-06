require 'minitest/autorun'
require './secret_santa'
require 'byebug'

class CommunityTest < Minitest::Test
  def setup
    input = ['Frank Grimes',
      'Homer Simpson, Marge Simpson',
      'Carl Carlson, Lenny Leonard',
      'Bart Simpson',
      'Lisa Simpson',
      'Maude Flanders, Ned Flanders']

    @giftee_with_partner = Giftee.new('Homer Simpson', 'Marge Simpson')
    @single_giftee = Giftee.new('Bart Simpson')
    @community = Community.parse(input)
  end

  def test_parse
    assert_includes @community.names, 'Frank Grimes'
    assert_includes @community.names, 'Marge Simpson'
  end

  def test_people_count
    assert_equal 9, @community.people.count
  end

  def test_that_oneself_and_partner_cannot_be_santas
    18.times do
      refute_includes @giftee_with_partner.forbidden_gifters, @community.secret_santa_for(@giftee_with_partner).values.last
    end
  end

  def test_that_santas_are_not_duplicated_nor_neglected
    18.times do
      assigned_santas = @community.secret_santas.keys
      assert_equal 9, assigned_santas.count
      assert_equal assigned_santas.count, assigned_santas.uniq.count
    end
  end
end
