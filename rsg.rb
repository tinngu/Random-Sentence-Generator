# Extracts just the definitions from the grammar file
# Returns an array of strings where each string is the lines for
# a given definition (without the braces)
def read_grammar_defs(filename)
  filename = 'grammars/' + filename unless filename.start_with? 'grammars/'
  filename += '.g' unless filename.end_with? '.g'
  contents = open(filename, 'r') { |f| f.read }
  contents.scan(/\{(.+?)\}/m).map do |rule_array|
    rule_array[0]
  end
end

# Takes data as returned by read_grammar_defs and reformats it
# in the form of an array with the first element being the
# non-terminal and the other elements being the productions for
# that non-terminal.
# Remember that a production can be empty (see third example)
# Example:
#   split_definition "\n<start>\nYou <adj> <name> . ;\nMay <curse> . ;\n"
#     returns ["<start>", "You <adj> <name> .", "May <curse> ."]
#   split_definition "\n<start>\nYou <adj> <name> . ;\n;\n"
#     returns ["<start>", "You <adj> <name> .", ""]
def split_definition(raw_def)
  # To separate the first nonterminal string in the array
  # A ';' semicolon is added after the index of '>' because
  # Elements are split by the delimiter ';'
  firstnonTermIndex = raw_def.index('>')
  raw_def.insert(firstnonTermIndex+1, ';')
  contents = raw_def.gsub(/\s+/,' ').strip.split(';')
  contents = contents.map!{|x| x.strip}
end


# Takes an array of definitions where the definitions have been
# processed by split_definition and returns a Hash that
# is the grammar where the key values are the non-terminals
# for a rule and the values are arrays of arrays containing
# the productions (each production is a separate sub-array)

# Example:
# to_grammar_hash([["<start>", "The   <object>   <verb>   tonight."], ["<object>", "waves", "big    yellow       flowers", "slugs"], ["<verb>", "sigh <adverb>", "portend like <object>", "die <adverb>"], ["<adverb>", "warily", "grumpily"]])
# returns {"<start>"=>[["The", "<object>", "<verb>", "tonight."]], "<object>"=>[["waves"], ["big", "yellow", "flowers"], ["slugs"]], "<verb>"=>[["sigh", "<adverb>"], ["portend", "like", "<object>"], ["die", "<adverb>"]], "<adverb>"=>[["warily"], ["grumpily"]]}
def to_grammar_hash(split_def_array)
  Hash[split_def_array.collect {|x|
    # Makes the first element the key and splits the rest, also removing extra white spaces
    [x[0],x.drop(1).map{|x| x.split(' ')}]}]
end

# Returns true iff s is a non-terminal
# a.k.a. a string where the first character is <
#        and the last character is >
def is_non_terminal?(s)
  # A simple check to see if the first and last
  # characters are the opening and closing arrow
  if s[0] == '<' && s[s.length-1] == '>'
    return true
  end
end

# Given a grammar hash (as returned by to_grammar_hash)
# returns a string that is a randomly generated sentence from
# that grammar
#
# Once the grammar is loaded up, begin with the <start> production and expand it to generate a
# random sentence.
# Note that the algorithm to traverse the data structure and
# return the terminals is extremely recursive.
#
# The grammar will always contain a <start> non-terminal to begin the
# expansion. It will not necessarily be the first definition in the file,
# but it will always be defined eventually. Your code can
# assume that the grammar files are syntactically correct
# (i.e. have a start definition, have the correct  punctuation and format
# as described above, don't have some sort of endless recursive cycle in the
# expansion, etc.). The names of non-terminals should be considered
# case-insensitively, <NOUN> matches <Noun> and <noun>, for example.
def expand(grammar, non_term="<start>")
  sentence = "" # Starting with an empty string
  grammar.each{|key,array|
      if key == non_term # Check if the key matches
        random = array.sample # Picks a random array element
        random.each { |x|
          if is_non_terminal?(x)
            sentence += expand(grammar, x)
          else
            sentence += x + ' '
          end
        }
        end
  }

  # Correcting white spaces around punctuations
  # Also fixing some glitches from the grammar files
  sentence.gsub(' ,', ',').gsub('. *', '.').gsub(',.', '.').gsub(' .', '.').gsub(' (', '(').gsub(') ', ')').gsub(' ?', '?')
end

# Given the name of a grammar file,
# read the grammar file and print a
# random expansion of the grammar
def rsg(filename)
  #Pretty much just combining all of the functions created above
  # to generate a random sentence from a given grammar file
  splitdefs = read_grammar_defs(filename).map {|x| split_definition(x)}
  gHash = to_grammar_hash(splitdefs)
  expand(gHash).rstrip
end

if __FILE__ == $0
  # prompt the user for the name of a grammar file
  # rsg that file
  begin
      print "Enter the filename for random grammars or type No to end: "
      filename = gets
      # when using gets, there is a newline at the end from enter
      filename.delete!("\n")

      # splat, cool way to compare a string to many other strings with include
      if %w(No no NO nO n nah nay nope NOPE nope N end).include? filename
        break
      end
      puts "==================================================================="
      puts rsg(filename)
      puts "==================================================================="
  end while filename != "no" || filename != "No" || filename != "NO"

end


#Helpful:
# require './rsg.rb'
# https://ruby-doc.org/core-2.2.0/Regexp.html
# https://ruby-doc.org/core-2.1.4/String.html