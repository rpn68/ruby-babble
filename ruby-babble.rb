#################
#
# Moved to Bitbucket
# V2
#
#################

##################
# FUNCTIONALITY #
#################

# Note: all numbers are started at 0, not 1. To find the first page of a book, look for page 0
#
# Address format: Hex_Value:Wall:Shelf:Volume:Page
#
# Examples:
#
#     98756SDH987S:2:3:14:345
#     HELLO:0:0:0:0
#
# Run the file from the command line with an action argument. The following arguments are supported:
#
#     checkout <addr> Checks out a page of a book. Also displays the page's title.
#     search <text> Does 3 searches for the text you input.
#         Page contains: Finds a page which contains the text.
#         Page only contains: Finds a page which only contains that text and nothing else.
#         Title match: Finds a title which is exactly this string. For a title match, it will only match the first
#           25 characters. Addresses returned for title matches will need to have a page number added to the tail end,
#           since they lack this.

###############
# EXPLANATION #
###############

# What was needed for this project was a way to generate seemingly random pages in a near-infinite address space which
# could also be searched for specific strings.
#
# I realized not early on that what I needed was not a reversible RNG, but in fact an encoding scheme to cleverly
# encode the page's text in the address of the book. Paired with a seeded RNG for shorter pages, I could reliably
# generate random pages, but also encode specific text into the page to be generated.
#
# To understand the encoding, you must think of the hex address of the book as a base-36 number and the text of the
# book as a base-29 number (26 letters plus space, comma, and period). The wall, shelf, volume, and page can be thought
# of as a base-10 number independent of the hex address. This base-10 number will be referred to as the location.
#
# Specifically, when text is searched for, that text is padded with a random amount of characters on it's front and
# back side, or in the case of the Page only contains, it's padded with spaces on it's back side. Then, a
# random number in the range of each location value is calculated.
#
# The page text is then converted from a string to a number. The location number is multiplied by a very large
# number and is then added to the page text number. Then the new page text number is converted into base-36, and
# that is the address.

LENGTH_OF_PAGE =  3239
# LOC_MULT = pow(30, LENGTH_OF_PAGE)
LOC_MULT = 30 ** LENGTH_OF_PAGE
TITLE_MULT = 30 ** 25

# 29 output letters: alphabet plus comma, space, and period
# alphanumeric in hex address (base 36): 3260
# in wall: 4
# in shelf: 5
# in volumes: 32
# pages: 410
# letters per page: 3239
# titles have 25 char

# main
def initialize
  puts "*** START ***"

  if ARGV[0] == "checkout"

    key_str = ARGV[1]
    puts "Title: #{getTitle( key_str )}"
    #puts getPage( key_str )

  end

  if ARGV[0] == "search"

  end

  puts "*** END ***"
end


def search( search_str )
  random = Random.new

  wall = (random.rand * 4 ).to_i.to_s
  shelf = ( random.rand * 5 ).to_i.to_s
  volume = ( random.rand * 32 ).to_i.to_s.rjust(2, '0')
  page = ( random.rand * 410 ).to_i.to_s.rjust(3, '0')

  # The string made up of all location address numbers
  loc_str = page + volume + shelf + wall
  loc_int = loc_str.to_i

  an = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'
  digs = 'abcdefghijklmnopqrstuvwxyz, .'
  hex_addr = ''
  depth = ( random.rand * ( LENGTH_OF_PAGE - search_str.length ) ).to_i

  # Randomized padding before searched-for text
  front_padding = ''
  depth.times do
    front_padding += digs[ ( random.rand * digs.length ).to_i ]
  end

  # Randomized padding after searched-for text
  back_padding = ''
  ( LENGTH_OF_PAGE - ( depth + search_str.length ) ).times do
    back_padding += digs[ ( random.rand * digs.length ).to_i ]
  end

  search_str = front_padding + search_str + back_padding
  hex_addr = int2base( stringToNumber( search_str ) + ( loc_int * LOC_MULT ), 36 )
  # Convert to base36, add loc_int, then convert to string
  key_str = hex_addr + ':' + wall + ':' + shelf + ':' + volume + ':' + page
  page_text = getPage( key_str )

  puts page_text

  key_str

end


def stringToNumber ( iString )
  digs = 'abcdefghijklmnopqrstuvwxyz, .'
  result = 0

  iString.length.times do | i |
    result += digs.index( iString[ iString.length - i - 1 ] ) * ( (29 ** i) )
  end
  result
end

def getTitle ( address )

  addressArray = address.split(':')
  hex_addr = addressArray[0]
  wall = addressArray[1]
  shelf = addressArray[2]
  volume = addressArray[3].rjust(2, '0')
  loc_int = ( volume + shelf + wall ).to_i
  key -= loc_int * TITLE_MULT
  str_36 = int2base( key, 36 )
  result = toText( str_36.to_i(36) )
  random = Random.new(result)
  if result.length < 25
    #add pseudorandom characters
    digs = 'abcdefghijklmnopqrstuvwxyz, .'
    while result.length < LENGTH_OF_PAGE
      result += digs[(random.rand * digs.length).to_i]
    end
  elsif result.length > 25
    result = result.chars.take(25)
  end
  result

end

def getPage ( address )

  hex_addr, wall, shelf, volume, page = address.split(':')
  volume = volume.rjust(2, '0')
  page = page.rjust(3, '0')
  loc_int = ( page + volume + shelf + wall ).to_i
  key = hex_addr.to_i(36)
  key -= loc_int * LOC_MULT
  str_36 = int2base( key, 36)
  result = toText( str_36.to_i(36) )

  if result.length < LENGTH_OF_PAGE
    # add pseudo-random characters
    random = Random.new(result)
    digs = 'abcdefghijklmnopqrstuvwxyz, .'
    while result.length < LENGTH_OF_PAGE
      result += digs[ (random.rand * digs.length).to_i ]
    end
  elsif result.length > LENGTH_OF_PAGE
    result = result.chars.take(LENGTH_OF_PAGE)
  end

  result

end

def int2base( x, base )

  digs = '0123456789' + 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

  if x < 0
    sign = -1
  elsif x == 0
    return digs[0]
  else
    sign = 1
  end

  x *= sign

  digits = []

  while x != 0
    digits << digs[x % base]
    x /= base
  end
  #digits.pop if digits.length > 0

  if sign < 0
    digits << '-'
  end

  digits.reverse.join

end

def toText( x )
  digs = 'abcdefghijklmnopqrstuvwxyz, .'

  if x < 0
    sign = -1
  elsif x == 0
    return digs[0]
  else
    sign = 1
  end

  x *= sign
  digits = []

  while x != 0
    digits << digs[x % 29]
    x /= 29
  end
  #digits.pop if digits.length > 0

  if sign < 0
    digits << '-'
  end

  digits.reverse.join

end


