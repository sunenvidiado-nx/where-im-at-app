import 'dart:math';

abstract class SadKaomojis {
  static String get random =>
      SadKaomojis.all[Random().nextInt(SadKaomojis.all.length)];

  static const all = [
    '~(>_<~)',
    '☆⌒(> _ <)',
    '☆⌒(>。<)',
    '(☆_@)',
    '(×_×)',
    '(x_x)',
    '(×_×)⌒☆',
    '(x_x)⌒☆',
    '(×﹏×)',
    '☆(＃××)',
    '(＋_＋)',
    '[ ± _ ± ]',
    '٩(× ×)۶',
    '_:(´ཀ`」 ∠):_',
    '(ﾒ﹏ﾒ)',
  ];
}
