# encoding: utf-8
require File.expand_path "../test_helper", __FILE__

class TestPairtree< Test::Unit::TestCase

  def self.should_convert_to_ppath value, expected, label
    should "convert to'#{value}' to #{expected} for #{label}" do
      assert_equal(expected, Orchard::Pairtree.id_to_ppath(value), expected)
    end
  end

  def self.should_roundtrip value, label
    should "roundtrip and equal #{value} for #{label}" do
      assert_equal(value,Orchard::Pairtree.decode(Orchard::Pairtree.encode(value)))
      assert_equal(value,Orchard::Pairtree.ppath_to_id(Orchard::Pairtree.id_to_ppath(value)))
    end
  end
      
  # ppath and roundtrip testing
  should_convert_to_ppath 'abc', 'ab/c/', 'basic 3 char - to_ppath'
  should_roundtrip 'abc', 'basic 3 char - roundtrip'
  should_convert_to_ppath 'abcd', 'ab/cd/', 'basic 4 char - to_ppath'
  should_roundtrip 'abcd', 'basic 4 char - roundtrip'
  should_convert_to_ppath 'xy', 'xy/', '2-char edge case - to_ppath'
  should_roundtrip 'xy', '2-char edge case - roundtrip'
  should_convert_to_ppath 'z', 'z/', '1-char edge case - to_ppath'
  should_roundtrip 'z', '1-char edge case - roundtrip'
  should_convert_to_ppath '12-986xy4', '12/-9/86/xy/4/', 'hyphen - to_ppath'
  should_roundtrip '12-986xy4', 'hyphen - roundtrip'
  should_convert_to_ppath '13030_45xqv_793842495', '13/03/0_/45/xq/v_/79/38/42/49/5/', 'long id with undescores - to_ppath'
  should_roundtrip '13030_45xqv_793842495', 'long id with undescores - roundtrip'
  should_convert_to_ppath 'ark:/13030/xt12t3', 'ar/k+/=1/30/30/=x/t1/2t/3/', 'colons and slashes - to_ppath'
  should_roundtrip 'ark:/13030/xt12t3', 'colons and slashes - roundtrip'
  should_convert_to_ppath 'hello world', 'he/ll/o^/20/wo/rl/d/', 'space - to_ppath'
  should_roundtrip 'hello world', 'space - roundtrip' 
  should_convert_to_ppath '/', '=/', '1-separator-char edge case - to_ppath'
  should_roundtrip '/', '1-separator-char edge case - roundtrip'  
  should_convert_to_ppath 'http://n2t.info/urn:nbn:se:kb:repos-1', 'ht/tp/+=/=n/2t/,i/nf/o=/ur/n+/nb/n+/se/+k/b+/re/po/s-/1/', 'a URL with colons, slashes, and periods - to_ppath'
  should_roundtrip 'http://n2t.info/urn:nbn:se:kb:repos-1', 'a URL with colons, slashes, and periods - roundtrip'
  should_convert_to_ppath 'what-the-*@?#!^!?', 'wh/at/-t/he/-^/2a/@^/3f/#!/^5/e!/^3/f/', 'weird chars from spec example - to_ppath'
  should_roundtrip 'what-the-*@?#!^!?', 'weird chars from spec example - roundtrip'
  should_convert_to_ppath '\\"*+,<=>?^|', '^5/c^/22/^2/a^/2b/^2/c^/3c/^3/d^/3e/^3/f^/5e/^7/c/', 'all weird visible chars - to_ppath'
  should_roundtrip '\\"*+,<=>?^|', 'all weird visible chars - roundtrip'
  
  # test roundtrip for many characters
  should_roundtrip 'asdfghjklpoiuytrewqxcvbnm1234567890:;/', 'basic - roundtrip'  
  should_roundtrip 'Années de Pèlerinage', 'french unicode - roundtrip'
  should_roundtrip 'ウインカリッスの日本語', 'japanese unicode - roundtrip'
  should_roundtrip '"""   1. Euro Symbol: €.
     2. Greek: Μπορώ να φάω σπασμένα γυαλιά χωρίς να πάθω τίποτα.
     3. Íslenska / Icelandic: Ég get etið gler án þess að meiða mig.
     4. Polish: Mogę jeść szkło, i mi nie szkodzi.
     5. Romanian: Pot să mănânc sticlă și ea nu mă rănește.
     6. Ukrainian: Я можу їсти шкло, й воно мені не пошкодить.
     7. Armenian: Կրնամ ապակի ուտել և ինծի անհանգիստ չըներ։
     8. Georgian: მინას ვჭამ და არა მტკივა.
     9. Hindi: मैं काँच खा सकता हूँ, मुझे उस से कोई पीडा नहीं होती.
    10. Hebrew(2): אני יכול לאכול זכוכית וזה לא מזיק לי.
    11. Yiddish(2): איך קען עסן גלאָז און עס טוט מיר נישט װײ.
    12. Arabic(2): أنا قادر على أكل الزجاج و هذا لا يؤلمني.
    13. Japanese: 私はガラスを食べられます。それは私を傷つけません。
    14. Thai: ฉันกินกระจกได้ แต่มันไม่ทำให้ฉันเจ็บ
    15. Pairtree: 🍐🌳 (U+1F350 U+1F333)"""', 'hardcore unicode test - roundtrip'

  # test ppath for french
  should_convert_to_ppath 'Années de Pèlerinage','An/n^/c3/^a/9e/s^/20/de/^2/0P/^c/3^/a8/le/ri/na/ge/' ,'french unicode - to_ppath'
  
  should "iterate a pairtree" do
    options = {:raise_errors => true}
    Orchard::Pairtree.iterate('test/mock/pairtree_root/', options) do |path| 
      assert_equal('pairtree_root/ab/cd/e/object', path.match('pairtree_root/ab/cd/e/object')[0])
    end
  end
  
  should "iterate pairtree and raise error" do
    options = {:raise_errors => true}
    assert_raise(Orchard::UnexpectedPairpathError) { Orchard::Pairtree.iterate('test/', options) {|path|}}
  end
  
  should "iterate pairtree and handle error" do
    options = {:raise_errors => false, :error_handling => Proc.new{|e| raise HandledError}}
    assert_raise(HandledError) { Orchard::Pairtree.iterate('test/', options) {|path|}}
  end
end
