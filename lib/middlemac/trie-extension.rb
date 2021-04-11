################################################################################
# Extend fast_trie gem with the ability to put the trie into our hash format.
################################################################################

class Trie

  # Convert the Trie to Hash.
  def to_h
    { "_" => self.to_h_impl(self.root) }
  end


  # Recursive implementation function for `to_h`.
  def to_h_impl(root)

    result = {}

    ('a'..'z').each do |i|
      if root.walk(i)

        result[i] = {} unless result.key?(i)

        if root.walk(i).terminal?
          result[i]['$'] = root.walk(i).value
        end

        unless root.walk(i).leaf?
          result[i]['_'] = self.to_h_impl(root.walk(i))
        end

      end
    end

    result
  end

end # class Trie
