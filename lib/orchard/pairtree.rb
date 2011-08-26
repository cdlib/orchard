require 'find'
module Orchard
  # Provides a set of methods for working with Pairtree paths.
  class Pairtree
    MAX_SHORTY = 2
    ENCODE_REGEX = /[\"*+,<=>?\\^|]|[^\x21-\x7e]/u
    DECODE_REGEX = /\^(..)|(.)/u
    PPATH_REGEX = /^(?:pairtree_root\/)?((?>[^:\/\.|.]{2}\/)*[^:\/\.|.]{1,2})(?:\/?$)/
    CHAR_ENCODE_CONV = {'/'=>'=',':'=>'+','.'=>','}
    CHAR_DECODE_CONV = {'='=>'/','+'=>':',','=>'.'}
    
    # ---------------------------
    # Instance Methods
    # ---------------------------    
    def initialize(*args)
      path = args[0]
      options = args[1] || {}
      
    end
    
    def each
      dirs = ["pairtree_root"]
      excludes = []
      for dir in dirs
        Find.find(dir) do |path|
          if FileTest.directory?(path)
            if excludes.include?(File.basename(path))
              Find.prune       # Don't look any further into this directory.
            else
              next
            end
          else
            p path
          end
        end
      end   
    end
    
    def test(path)
       begin
         if File.lstat(path).directory?
           begin
             dir = Dir.open(path)
             dir.each do |f|
               unless f == "." or f == ".."
                 test(f)
               end             
              end
           ensure
             dir.close
           end
         end
       end
    end
    
    # ---------------------------
    # Class Methods
    # ---------------------------
    # Encodes a given +id+ <em>(String)</em> according to the "identifier string 
    # cleaning" in the pairtree 0.1 specification. 
    #
    #   encode(id)
    #
    # ==== Examples
    #
    #   Pairtree.encode('ark:/13030/xt12t3')
    #   # => ark+=13030=xt12t3
    #
    #   Pairtree.encode('http://n2t.info/urn:nbn:se:kb:repos-1')
    #   # => http+==n2t,info=urn+nbn+se+kb+repos-1
    #
    #   Pairtree.encode('what-the-*@?#!^!?')
    #   # => what-the-^2a@^3f#!^5e!^3f
    #
    # ==== Explanation (From Pairtree 0.1 Specification)
    #
    #   Identifier string cleaning
    #
    #   Prior to splitting into character pairs, identifier strings are cleaned in 
    #   two separate steps. One step would be simpler, but pairtree is designed so 
    #   that commonly used characters in reasonably opaque identifiers (e.g., not 
    #   containing natural language words, phrases, or hints) result in reasonably 
    #   short and familiar-looking paths. For completeness, the pairtree  algorithm 
    #   specifies what to do with all possible UTF-8 characters, and relies for this 
    #   on a kind of URL hex-encoding. To avoid conflict with URLs, pairtree 
    #   hex-encoding is introduced with the '^' character instead of '%'.
    #
    #   First, the identifier string is cleaned of characters that are expected to 
    #   occur rarely in object identifiers but that would cause certain known 
    #   problems for file systems. In this step, every UTF-8 octet outside the range 
    #   of visible ASCII (94 characters with hexadecimal codes 21-7e) [ASCII], as 
    #   well as the following visible ASCII characters, must be converted to 
    #   their corresponding 3-character hexadecimal encoding, ^hh, where ^ is a 
    #   circumflex and hh is two hex digits. For example, ' ' (space) is converted 
    #   to ^20 and '*' to ^2a. In the second step, the following single-character to 
    #   single-character conversions must be done. These are characters that occur 
    #   quite commonly in opaque identifiers but present special problems for 
    #   filesystems. This step avoids requiring them to be hex encoded (hence 
    #   expanded to three characters), which keeps the typical ppath reasonably 
    #   short. Here are examples of identifier strings after cleaning and after 
    #   ppath mapping.
    # 
    def self.encode(id)
      #first pass
      first_pass_id = id.gsub(ENCODE_REGEX) { |m| m.bytes.map{|b| "^%02x"%b }.join}
    
      # second pass
      second_pass_id = first_pass_id.split(//).collect { |char| CHAR_ENCODE_CONV[char] || char}.join
    end 

    # Decodes a given +id+ <em>(String)</em>according to the pairtree 0.1 specifiaation. 
    #
    #   encode(id)
    #
    # ==== Examples
    #
    #   Pairtree.decode('ark+=13030=xt12t3')
    #   # => ark:/13030/xt12t3
    #
    #   Pairtree.decode('http+==n2t,info=urn+nbn+se+kb+repos-1')
    #   # => http://n2t.info/urn:nbn:se:kb:repos-1
    #
    #   Pairtree.decode('what-the-^2a@^3f#!^5e!^3f')
    #   # => what-the-*@?#!^!?
    #
    def self.decode(id)
      # first pass (reverse second from encode)
      first_pass_id = id.split(//).collect { |char| CHAR_DECODE_CONV[char] || char}.join
    
      # second pass (reverse first from encode)
      second_pass_id = first_pass_id.scan(DECODE_REGEX).map {|coded,chr| coded.nil? ? chr.ord : coded.hex}.pack('C*').force_encoding('utf-8')
    end

    # Constructs the pairpath for a given +id+ <em>(String)</em> and +options+. 
    #
    #   id_to_ppath(id, options = {})
    #
    # ==== Options
    # * <tt>:prefix => Pairtree prefix</tt> - This will remove the prefix from the id
    #   before creating a pairpath. (String)
    #
    # ==== Examples
    #
    #   Pairtree.id_to_ppath('abcde')
    #   # => ab/cd/e
    #
    # or with the prefix option
    #
    #   Pairtree.id_to_ppath('http://dom.org/abcde', :prefix => 'http://dom.org/')
    #   # => ab/cd/e
    #
    # ==== Explanation (From Pairtree 0.1 Specification) The basic pairtree algorithm
    #
    #   The pairtree algorithm maps an arbitrary UTF-8 [RFC3629] encoded identifier 
    #   string into a filesystem directory path based on successive pairs of 
    #   characters, and also defines the reverse mapping (from pathname to 
    #   identifier).
    #
    #   In this document the word "directory" is used interchangeably with the word 
    #   "folder" and all examples conform to Unix-based filesystem conventions which 
    #   should tranlate easily to Windows conventions after substituting the path 
    #   separator ('\' instead of '/'). Pairtree places no limitations on file and 
    #   pathlengths, so implementors thinking about maximal interoperation may 
    #   wish to consider the issues listed in the Interoperability section of 
    #   this document.
    #
    #   The mapping from identifier string to path has two parts. First, the string 
    #   is cleaned by converting characters that would be illegal or especially 
    #   problemmaticin Unix or Windows filesystems. The cleaned string is then 
    #   split into pairs of characters, each of which becomes a directory name 
    #   in a filesystem path: successive pairs map to successive path components 
    #   until there are no characters left, with the last component being either 
    #   a 1- or 2-character directory name. The resulting path is known as 
    #   a pairpath, or ppath.
    #
    #   abcd	-> ab/cd/ 
    #   abcdefg	-> ab/cd/ef/g/ 
    #   12-986xy4 -> 12/-9/86/xy/4/
    #
    def self.id_to_ppath(*args)
      id = args[0]
      options = args[1] || {}
      id.sub!(/^#{options[:prefix]}/,'') unless options[:prefix].nil?
      self.string_to_dirpath(self.encode(id), MAX_SHORTY)
    end

    # Reconstructs the id for a given +pairpath+ and +options+. 
    #
    #   ppath_to_id(id, options = {})
    #     # id is a String
    #
    # ==== Options
    # * <tt>:prefix => Pairtree prefix</tt> - This will remove the prefix from the id
    #   before creating a pairpath. (String)
    #
    # ==== Examples
    #
    #   Pairtree.ppath_to_id('ab/cd/e')
    #   # => abcde
    #
    # or with the prefix option
    #
    #   Pairtree.ppath_to_id('ab/cd/e', :prefix => 'http://dom.org/')
    #   # => http://dom.org/abcde
    #  
    def self.ppath_to_id(*args)
      ppath = args[0]
      options = args[1] || {}
      match = ppath.match(PPATH_REGEX)
      if match.nil? 
        throw InvalidPPathError 
      end
      id = self.decode(match[1].delete('/'))
      options[:prefix].nil? ? id : options[:prefix] + id
    end
    
    # Iterates a given +pairpath+ with a +block+. 
    #
    #   iterate(pairtree_path,options,&block)
    #     # pairtree_path is a String
    #
    # ==== Options
    # * <tt>:raise_errors => Raise encountered errors/tt> - This will show (true) or surpress 
    #   (false) ecountered errors. (Boolean)
    # * <tt>:error_handling => Function to call on error</tt> - The Proc will execute if errors occur.
    #   Error passed into Proc as parameter. (Proc or Nil)
    #
    # ==== Examples
    #
    #   Pairtree.iterate('repo/pairtree_root/', true) do |path|
    #     puts path
    #   end
    #   # => /absolute_path/repo/pairtree_root/ab/cd/e/object
    #   ...
    #   # => /absolute_path/repo/pairtree_root/xy/z/object
    #
    def self.iterate(*args,&block)
      #pairtree_path,raise_errors=false,error_handling=nil,&block
      ppath = args[0]
      options = args[1] || {}
      Find.find(ppath) do |entry|
        begin
          if File.directory?(entry)
            case entry
            when /^.*\/[^\/:.]{1,2}$/ # in pairtree
            when /^.*[^\/]{3,}$/ # found object
              block.call(File.absolute_path(entry))
              Find.prune
            when ppath # ignore initial path
            else
              raise UnexpectedPairpathError, File.absolute_path(entry)
            end
          else
            raise UnexpectedPairpathError, File.absolute_path(entry)
          end
        rescue Exception => e
          options[:error_handling].call(e) unless options[:error_handling].nil?
          raise e if options[:raise_errors] == true
        end
      end
    end
    
    private
    # Internal - split a string into a directory path by shorty length.
    def self.string_to_dirpath(s, dir_length_max)
      s.gsub(/(.{#{dir_length_max}}|.{1,#{dir_length_max}}$)/) { |m| $1.nil? ? m : m + '/' }
    end
  end
end