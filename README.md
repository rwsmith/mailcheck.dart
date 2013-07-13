Mailcheck.dart
==============

This is a port of Mailcheck.js (see their excellent work here https://github.com/Kicksend/mailcheck) to Dart.
Mailcheck offers suggestions for potentially misspelled email addresses based on a list you can modify.

Example Scenario
----------------

####What if a user enters in "me@hot*w*ail.com" to an input field? (*Note the misspelling)*  
Most likely, this user meant to enter in "me@hot*m*ail.com". Mailcheck.dart allows you to offer suggestions to users if they mispell a domain. In this case, ```me@hotmail.com``` would be suggested.  

####Example Usage:
Mailcheck.dart is simple to use. To get started, you should install the library via [Pub](http://pub.dartlang.org/doc/). Here is a simple example:

```
import 'package:mailcheck/mailcheck.dart';  
main()   
{  
    MailChecker m = new MailChecker("hello@jotmail.com");  
    print(m.simpleSuggest()); //will return hello@hotmail.com
}  
``` 

Modifying The Default List
------------------------------
Mailcheck.dart uses a default list to determine suggestions for email domains. This list is stored in every instance of a ```Mailchecker``` object as ```domains```. So, you can do something like this:  
```
MailChecker m = new MailChecker("me@myvompany.com");  
m.domains.add("mycompany.com");  
print(m.simpleSuggest()); //will return me@mycompany.com
```  

Credits
---------
This idea and much of the code comes from the excellent work by Derrick Ko and Wei Lu, at https://github.com/Kicksend/mailcheck. Their JavaScript version is currently used by Dropbox, Kickstarter, The Verge, and several others. 

Contributing
----------------
Please feel free to send feature requests, bug reports, *or* pull requests for feature additions/bug fixes. I have done testing, but since this is my first Dart project (and library), please feel free to make suggestions to my code as well (to make it conform better to the Dart style guide, more efficient, etc). 