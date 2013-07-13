import 'package:mailcheck/mailcheck.dart';
main()
{
  MailChecker m = new MailChecker("hello@myvompany.com");
  m.domains.add("mycompany.com");
  print(m.simpleSuggest());
}