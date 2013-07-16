library mailcheck;


/**
 * MailChecker Class, based on excellent work here: <https://github.com/Kicksend/mailcheck>
 * 
 * Ported to Dart (minor changes from JS version) by [Ryan Smith](http://github.com/rwsmith)
 * 
 * MailChecker *suggests* the correct domain and TLD of an email address (in case a user entered in something mis-spelled).
 * 
 * Example usage:
 *     MailChecker m = new MailChecker("me@hotwail.com"); //note mis-spelling
 *     print(m.simpleSuggest()); //will return me@hotmail.com
 *     
 *     MailChecker m = new MailChecker("me@hotmail.com"); //note proper spelling
 *     print(m.simpleSuggest()); //will return empty string
 */
class MailChecker
{
  String emailStr;
  
  int _threshold;
  /// The default list of domains to match against. Modify, if needed, after creating a `MailCheck` object, and before calling [suggest()] or [simpleSuggest()].
  List<String> domains = ["yahoo.com", "google.com", "hotmail.com", "gmail.com", "me.com", "aol.com", "mac.com", "live.com", "comcast.net", "googlemail.com", "msn.com", "hotmail.co.uk", "yahoo.co.uk", "facebook.com", "verizon.net", "sbcglobal.net", "att.net", "gmx.com", "mail.com"];
  
  /// The default list of TLDs. Modify, if needed, after creating a `MailChecker` object, and before calling [suggest()] or [simpleSuggest()]. 
  List<String> topLevelDomains = ["co.uk", "com", "net", "org", "info", "edu", "gov", "mil"];
  
  /**
   * Parameter String [email] is the email address you want to check
   * 
   * Optional int [threshold] to adjust the threshold - minimum distance to assume match. It is suggested you leave [threshold] at the default value.
   */
  MailChecker(String email, [int threshold = 3])
  {
     emailStr = email;
     _threshold = threshold;
  }
  
  MailCheckerEmail _splitEmail()
  {
    //Creates a MailCheckerEmail object from this.emailStr
    List<String> parts = emailStr.split("@");
    if (parts.length < 2) //Invalid email
      return null;
    for (String i in parts) //Also invalid..
      if (i == "") return null;
    String domain = parts.removeLast(); //equivalent to parts.pop()
    List<String> domainParts = domain.split(".");
    String tld = "";
    if (domainParts.isEmpty)
    {
      //Wasn't a ., not a TLD
      return null;
    }
    else if (domainParts.length == 1)
    {
      //Domain only has TLD (valid under RFC)
      tld = domainParts[0];
    }
    else
    {
      //Here we parse TLDs like .com, .co.uk
      for (int i = 1; i < domainParts.length; i++) {
        //Include everything in tld except first element (which is domain, not tld)
        tld += domainParts[i] + '.';
      }
      if (domainParts.length >= 2) {
        tld = tld.substring(0, tld.length - 1); //remove '.' in, for example, 'com.'
      }
    }
    
    return new MailCheckerEmail(parts.join("@"), domain, tld);
    
  }
  
  /**
   * Similiar to [suggest()] method, returns the full suggestion (such as me@hotmail.com).
   *
   *  If no suggestions are available, an empty string is returned. This means that email is either perfect, or, there is no possible suggestion.
   * 
   * An example scenario:
   * 
   * * If a non-empty string is returned, offer the user a chance to change to the suggestion provided.
   * 
   * * If an empty string is returned, allow the application to continue normally (do not offer to change to suggestion)
   *
   */
  String simpleSuggest()
  {
   MailCheckerSuggestion s = suggest();
   if (s == null) return "";
   return s.full;
  }
  
  /**
   * Returns a MailCheckerSuggestion object, containing the suggested attributes of the suggestion
   * 
   * Most users are likely more interested in the [simpleSuggest()] method
   * 
   * A MailCheckerSuggestion has three attributes that contain the data of the suggestion:
   * 
   * Assume the email address provided is `me@hotwail.com` (note mis-spelling) and suggested change is `me@hotmail.com`
   * 
   * * [address]: part before @ sign, ie: `me` in `me@hotmail.com`
   * 
   * * [domain]: part after @ sign, ie: `hotmail.com` in `me@hotmail.com`
   * 
   * * [full]: the full suggestion, ie: if user supplies `me@hotwail.com`, full suggestion would be `me@hotmail.com`
   */
  MailCheckerSuggestion suggest()
  {
     String email = emailStr.toLowerCase();
     MailCheckerEmail emailParts = _splitEmail();
     //print("${emailParts.toString()}");
     String closestDomain = _findClosestDomain(emailParts.domain, domains);
     if (closestDomain != null)
     {
        if (closestDomain != emailParts.domain) //we have a close match
          return new MailCheckerSuggestion(emailParts.address, closestDomain, emailParts.address + "@" + closestDomain);
     }
     else
     {
      //not a close match...mis-spell tld?
      String closestTopLevelDomain = _findClosestDomain(emailParts.topLevelDomain, topLevelDomains);
      if (closestTopLevelDomain != null && closestTopLevelDomain != emailParts.topLevelDomain)
      {
        //May be mis-spelled TLD
        String domain = emailParts.domain;
        closestDomain = domain.substring(0, domain.lastIndexOf(emailParts.topLevelDomain)) + closestTopLevelDomain;
        return new MailCheckerSuggestion(emailParts.address, closestDomain, emailParts.address + "@" + closestDomain);

      }
     }
     return null; //Cannot find a suggestion
  }
  
  String _findClosestDomain(String domain, List<String> domains)
  {
   //Attempts to find closest domain such as gmail.com
   //If it cannot, it will return null
   double dist = 0.0;
   double minDist = 99.0;
   String closestDomain = null;
   for (int i = 0; i<domains.length; i++)
   {
     if (domain == domains[i]) //found exact match
       return domain;
     dist = _sift3Distance(domain, domains[i]);
     if (dist < minDist)
     {
       minDist = dist;
       closestDomain = domains[i];
     }
   }

   if (minDist <= _threshold && closestDomain != null) 
     return closestDomain;
    else 
     return null;
   }

  
  double _sift3Distance(String s1, String s2)
  {
    //Sift3 Distance method
    // Uses sift3: http://siderite.blogspot.com/2007/04/super-fast-and-accurate-string-distance.html
    if (s1 == null || s1.length == 0) {
      if (s2 == null || s2.length == 0) {
        return 0.0;
      } else {
        return s2.length.toDouble();
      }
    }

    if (s2 == null || s2.length == 0) {
      return s1.length.toDouble();
    }

    int c = 0;
    int offset1 = 0;
    int offset2 = 0;
    int lcs = 0;
    int maxOffset = 5;
    while ((c + offset1 < s1.length) && (c + offset2 < s2.length)) {
      if (s1[c + offset1] == s2[c + offset2]) {
        lcs++;
      } else {
        offset1 = 0;
        offset2 = 0;
        for (int i = 0; i < maxOffset; i++) {
          if ((c + i < s1.length) && (s1[c + i] == s2[c])) {
            offset1 = i;
            break;
          }
          if ((c + i < s2.length) && (s1[c] == s2[c + i])) {
            offset2 = i;
            break;
          }
        }
      }
      c++;
    }
    return (s1.length + s2.length) / 2 - lcs;
  }
  
  
}

/**
 * A class you should not have to create with new keyword. It is used by [MailChecker], and stores three attributes:
 * 
 * *[address]: part before @ sign (`me` in `me@hotmail.com`)
 * 
 * *[domain]: part after @ sign (`hotmail.com` in `me@hotmail.com`)
 * 
 * *[topLevelDomain] (`com` in `me@hotmail.com`)
 * 
 */
class MailCheckerEmail
{
  final String address; //before @ sign
  final String domain; //after @ sign
  final String topLevelDomain; //TLD such as .com
  
  const MailCheckerEmail(this.address, this.domain, this.topLevelDomain);
 
  String toString() => address + " " + domain + " " + topLevelDomain;
  
}

/**
 * A class you should not have to create with new keyword. It is returned by [MailChecker.suggest] and has three attributes:
 * 
 * *[address]: The suggested address (does not change)
 * 
 * *[domain]: The suggested domain 
 * 
 * *[full]: The full suggested string, use [MailChecker().simpleSuggest()] to access this
 */
class MailCheckerSuggestion
{
 final String address;
 final String domain;
 final String full; //full suggestion
 const MailCheckerSuggestion(this.address, this.domain, this.full);

 
}
