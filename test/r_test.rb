require 'test/unit'

class RTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  # Fake test
  def test_simple
    assert_equal( 0, stringToNumber('a') )
    assert_equal( 29, stringToNumber('ba') )

    assert_equal( LENGTH_OF_PAGE, getPage('asasrkrtjfsdf:2:2:2:33').length )
    assert_equal( 'liger', toText( int2base( stringToNumber( 'liger' ), 36 ).to_i(36) ) )
    assert_equal( 'hello kitty', toText( int2base( stringToNumber( 'hello kitty' ), 36 ).to_i(36) ) )
    assert_equal( 'now is the time for all good men to come to the aid of their country.', toText( int2base( stringToNumber( 'now is the time for all good men to come to the aid of their country.' ), 36 ).to_i(36) ) )
    refute_equal( 'now is the time for all good men to come to the aid of their country.', toText( int2base( stringToNumber( 'now is the time for all good men to come to the aid of there country.' ), 36 ).to_i(36) ) )

    assert_equal( '4', int2base( 4, 36 ) )
    assert_equal( 'A', int2base( 10, 36 ) )

    test_string = '.................................................'
    assert_match( Regexp.new(Regexp.escape(test_string)), getPage( search( test_string) ) )
    refute_match( Regexp.new('Who is John Galt'), getPage( search( test_string) ) )
    #getPage( search( test_string ) )
  end

end